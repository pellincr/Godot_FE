extends Control

class_name archetypeDraftSelector

signal archetype_selected(archetype)

var playerOverworldData : PlayerOverworldData

var menu_hover_effect = preload("res://resources/sounds/ui/menu_cursor.wav")
var menu_enter_effect = preload("res://resources/sounds/ui/menu_confirm.wav")


@onready var main_container = $Panel/MainVContainer
@onready var header_label = $Panel/MainVContainer/HeaderLabel
@onready var archetype_list_container = $Panel/MainVContainer/ArchetypeListContainer
@onready var archetype_icon_container = $Panel/MainVContainer/ArchetypeIconContainer

@onready var archetype:ArmyArchetypeDefinition = null

var possible_rarities = {
	"common" : 60,
	"uncommon" : 25,
	"rare" : 10,
	"legendary" : 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	randomize_archetype()
	update_all()


func set_po_data(po_data):
	playerOverworldData = po_data

func set_header_label(text):
	header_label.text = text

func set_header_color(rarity : Rarity):
	if rarity:
		header_label.modulate = rarity.ui_color

func set_rarity_shadow_hue(rarity):
	if rarity:
		var panel_stylebox :StyleBoxFlat = theme.get_stylebox("panel","Panel").duplicate()
		panel_stylebox.set_shadow_color(rarity.ui_color)
		panel_stylebox.set_shadow_size(rarity.shadow_size)
		theme.set_stylebox("panel","Panel",panel_stylebox)

func clear_unit_list_container():
	var children = archetype_list_container.get_children()
	for child in children:
		child.queue_free()

func get_random_rarity():
	var total_weight : int
	for weight in possible_rarities.values():
		total_weight += weight
		
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for rarity in possible_rarities.keys():
		current_weight += possible_rarities[rarity]
		if random_value < current_weight:
			return rarity
	return "common"

# list-of-dictionaries -> null
#purpose: to use the given list of archetypes to fill in the selector card container
func fill_archetype_list_container(archetype_picks : Array[armyArchetypePickDefinition]):
	for pick:armyArchetypePickDefinition in archetype_picks:
		var archetype_label: Label = Label.new()
		var volume = pick.volume
		archetype_label.text =  str(volume) + " X " + pick.name
		archetype_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		archetype_list_container.add_child(archetype_label)
		while(volume > 0):
			add_to_archetype_icon_container(pick) #THIS WILL BE CHANGED WHEN PICKS GET THEIR ICONS
			volume-= 1


func add_to_archetype_icon_container(pick):
	#var icon = preload("res://resources/sprites/icons/UnitArchetype.png")
	#var texture = TextureRect.new()
	#texture.texture = icon
	#archetype_icon_container.add_child(texture)
	var icon
	if pick is armyArchetypePickWeaponDefinition:
		icon = preload("res://unit drafting/Archetype Draft/archetype_icons/item_archetype_icon.tscn").instantiate()
		icon.item_archetype_pick = pick
		archetype_icon_container.add_child(icon)
		icon.update_by_archetype_pick()
	else:
		icon = preload("res://unit drafting/Archetype Draft/archetype_icons/unit_archetype_icon.tscn").instantiate()
		icon.unit_archetype_pick = pick
		archetype_icon_container.add_child(icon)
		icon.update_by_archetype_pick()

func clear_archetype_icon_container():
	var children = archetype_icon_container.get_children()
	for child in children:
		child.queue_free()


func _on_focus_entered():
	$AudioStreamPlayer.stream = menu_hover_effect
	$AudioStreamPlayer.play()
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thick_border.tres")
	set_rarity_shadow_hue(archetype.rarity)
	print("Selection Focused")


func _on_focus_exited():
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thin_border.tres")

func _on_panel_mouse_entered():
	grab_focus()


func update_all():
	set_header_label(archetype.name)
	set_header_color(archetype.rarity)
	#var given_unit_archetypes = [archetype.given_unit_faction_archetypes, archetype.given_unit_trait_archetypes, archetype.given_unit_weapon_archetypes]
	clear_unit_list_container()
	clear_archetype_icon_container()
	fill_archetype_list_container(archetype.archetype_picks)


func randomize_archetype():
	var army_archetypes = ArmyArchetypeDatabase.army_archetypes.keys()
	var rarity: Rarity = RarityDatabase.rarities.get(get_random_rarity())
	var unlocked_army_archetypes = filter_archetypes_by_unlocked(army_archetypes)
	var chosen_rarity_archetypes = filter_archetypes_by_rarity(unlocked_army_archetypes,rarity)
	var chosen_archetype_key = chosen_rarity_archetypes.pick_random()
	archetype =  ArmyArchetypeDatabase.army_archetypes.get(chosen_archetype_key)


func filter_archetypes_by_unlocked(archetype_keys: Array) -> Array:
	var accum = []
	for archetype_key in archetype_keys:
		if playerOverworldData.unlock_manager.archetypes_unlocked.keys().has(archetype_key):
			if playerOverworldData.unlock_manager.archetypes_unlocked[archetype_key]:
				accum.append(archetype_key)
	return accum

func filter_archetypes_by_rarity(archetype_keys:Array, rarity:Rarity):
	var accum = []
	for key in archetype_keys:
		var archetype :ArmyArchetypeDefinition= ArmyArchetypeDatabase.army_archetypes[key]
		if archetype.rarity == rarity:
			accum.append(key)
	if accum.is_empty():
		return archetype_keys
	else:
		return accum

func _on_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_confirm") and has_focus():
			$AudioStreamPlayer.stream = menu_enter_effect
			$AudioStreamPlayer.play()
			archetype_selected.emit(archetype)
			print("Archetype Selected")
