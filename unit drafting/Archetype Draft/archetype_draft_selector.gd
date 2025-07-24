extends Control

class_name archetypeDraftSelector

signal archetype_selected(archetype)

@onready var selection_hovered = false

@onready var main_container = $Panel/MainVContainer
@onready var header_label = $Panel/MainVContainer/HeaderLabel
@onready var archetype_list_container = $Panel/MainVContainer/ArchetypeListContainer
@onready var archetype_icon_container = $Panel/MainVContainer/ArchetypeIconContainer

@onready var archetype:ArmyArchetypeDefinition = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_archetype()
	update_all()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_confirm") and selection_hovered:
		archetype_selected.emit(archetype)
		#randomize_archetype()
		#update_all()
		print("Archetype Selected")


func set_header_label(text):
	header_label.text = text

func clear_unit_list_container():
	var children = archetype_list_container.get_children()
	for child in children:
		child.queue_free()

# list-of-dictionaries -> null
#purpose: to use the given list of archetypes to fill in the selector card container
func fill_archetype_list_container(given_archetypes):
	for archetype_type in given_archetypes:
		for key in archetype_type.keys():
			var given_selection_amount = archetype_type.get(key)
			if given_selection_amount == 0:
				#If that selection in the current archetype dictionary has nothing, don't add it
				pass
			else:
				var archetype_label: Label = Label.new()
				archetype_label.text = str(given_selection_amount) + " X " + str(key)
				archetype_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				archetype_list_container.add_child(archetype_label)
				while given_selection_amount > 0:
					add_to_archetype_icon_container()
					given_selection_amount -= 1


func add_to_archetype_icon_container():
	var icon = preload("res://resources/sprites/icons/UnitArchetype.png")
	var texture = TextureRect.new()
	texture.texture = icon
	archetype_icon_container.add_child(texture)

func clear_archetype_icon_container():
	var children = archetype_icon_container.get_children()
	for child in children:
		child.queue_free()



func _on_panel_mouse_entered():
	selection_hovered = true
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thick_border.tres")
	print("Selection Hovered")


func _on_panel_mouse_exited():
	selection_hovered = false
	self.theme = preload("res://unit drafting/Unit_Commander Draft/draft_selector_thin_border.tres")
	print("Selection Exited")

func update_all():
	set_header_label(archetype.archetype_name)
	var given_unit_archetypes = [archetype.given_unit_faction_archetypes, archetype.given_unit_trait_archetypes, archetype.given_unit_weapon_archetypes]
	clear_unit_list_container()
	clear_archetype_icon_container()
	fill_archetype_list_container(given_unit_archetypes)


func randomize_archetype():
	var army_archetypes = ArmyArchetypeDatabase.army_archetypes.keys()
	var chosen_archetype_key = army_archetypes.pick_random()
	archetype =  ArmyArchetypeDatabase.army_archetypes.get(chosen_archetype_key)
