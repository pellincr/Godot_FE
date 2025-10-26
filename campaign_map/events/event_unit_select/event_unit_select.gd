extends Control

signal return_to_menu()
signal unit_selected(unit:Unit)
#signal unit_deselected(unit:Unit)

@onready var army_container: HBoxContainer = $VBoxContainer/ArmyContainer
@onready var selection_effect: RichTextLabel = $VBoxContainer/SelectionEffect
@onready var background: TextureRect = $background

var description : String 
var background_texture : Texture2D
var playerOverworldData : PlayerOverworldData
var event_selection_requirements #TO BE IMPL

func _ready() -> void:
	#SelectedSaveFile.save(playerOverworldData)
	army_container.unit_selection = true
	army_container.set_po_data(playerOverworldData)
	army_container.fill_army_scroll_container()
	army_container.connect("unit_panel_pressed",_on_army_scroll_container_unit_panel_pressed)
	selection_effect.text = description
	background.texture = background_texture
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		return_to_menu.emit()
		queue_free()


	
func set_description(text):
	self.description = text
	
func set_po_data(po_data):
	playerOverworldData = po_data

func clear_unit_detailed_view():
	if get_child_count() > 1:
		get_child(1).queue_free()

func _on_army_scroll_container_unit_panel_pressed(unit: Unit) -> void:
	# Create the confirmation button
	#link signal of confirm button 
	unit_selected.emit(unit)
	self.queue_free()

func grab_first_army_panel_focus():
	army_container.grab_first_army_panel_focus()
