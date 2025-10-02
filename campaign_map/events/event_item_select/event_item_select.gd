extends Control

signal item_panel_pressed(item)

@onready var main_container: VBoxContainer = $VBoxContainer/ItemContainer/ConvoyScrollContainer2/MainContainer
@onready var owner_name: Label = $VBoxContainer/OwnerInfoPanel/VBoxContainer/OwnerName
@onready var owner_icon: TextureRect = $VBoxContainer/OwnerInfoPanel/ownerIcon
@onready var item_container: HBoxContainer = $VBoxContainer/ItemContainer
@onready var background: TextureRect = $Background

var background_texture : Texture2D
var event_item_selection_info : Array
var focused := false	

func _ready() -> void:
	fill_convoy_scroll_container()
	#selection_effect.text = description
	background.texture = background_texture

func fill_convoy_scroll_container():
	for object in event_item_selection_info:
		var item_panel = preload("res://ui/battle_prep_new/item_panel/item_panel_container.tscn").instantiate()
		item_panel.item = object.item
		main_container.add_child(item_panel)
		item_panel.item_panel_pressed.connect(_on_item_panel_pressed)
		item_panel.focus_entered.connect(_on_item_panel_focused.bind(object.item))
		if !focused:
			item_panel.grab_focus()
			focused = true

func update_owner_info(object):
	owner_icon.texture = object.owner_icon
	owner_name.text = object.owner_name
	
func clear_main_container():
	var children = main_container.get_children()
	for child in children:
		child.queue_free()

func clear_detailed_view_container():
	var children = item_container.get_children()
	for child_index in children.size():
		if child_index != 0:
			children[child_index].queue_free()

func _on_item_panel_focused(item):
	clear_detailed_view_container()
	var weapon_detailed_info = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn").instantiate()
	weapon_detailed_info.item = item
	item_container.add_child(weapon_detailed_info)
	weapon_detailed_info.update_by_item()
	# ALSO update header
	var _entry = event_item_selection_info[get_focused_item_index()]
	update_owner_info(_entry)

func get_focused_item_index() -> int:
	var children = main_container.get_children()
	var focused_index = 0
	for index in children.size():
		if children[index].has_focus():
			focused_index =  index
			break
			
	return focused_index

func _on_item_panel_pressed(item):
	item_panel_pressed.emit(item)
	self.queue_free()

func reset_convoy_container():
	clear_main_container()
	fill_convoy_scroll_container()
