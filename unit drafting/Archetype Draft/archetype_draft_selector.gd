extends Control

class_name archetypeDraftSelector

signal archetype_selected(archetype)

@onready var selection_hovered = false

@onready var main_container = $Panel/MainVContainer
@onready var header_label = $Panel/MainVContainer/HeaderLabel
@onready var units_list_container = $Panel/MainVContainer/UnitListContainer
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
	var children = units_list_container.get_children()
	for child in children:
		child.queue_free()

func fill_unit_list_container(dictionary:Dictionary):
	for key in dictionary.keys():
		var dict_value = dictionary.get(key)
		if dict_value == 0:
			pass
		else:
			var unit_label: Label = Label.new()
			unit_label.text = str(dict_value) + " X "  + key
			unit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			units_list_container.add_child(unit_label)
			while dict_value > 0:
				add_to_archetype_icon_container()
				dict_value -= 1

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
	var allotted_units = archetype.given_archetypes
	clear_unit_list_container()
	clear_archetype_icon_container()
	fill_unit_list_container(allotted_units)


func randomize_archetype():
	var army_archetypes = ArmyArchetypeDatabase.army_archetypes.keys()
	var chosen_archetype_key = army_archetypes.pick_random()
	archetype =  ArmyArchetypeDatabase.army_archetypes.get(chosen_archetype_key)
