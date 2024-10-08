extends Control

@onready var main_container = get_node("MainVcontainer")
@onready var party_container = get_node("PartyVContainer")
@onready var shop_container = get_node("ShopVContainer")
@onready var recruit_container = get_node("RecruitVContainer")
@onready var training_container = get_node("TrainingVContainer")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")


func _on_manage_party_button_pressed():
	main_container.visible = false
	party_container.visible = true


func _on_return_button_pressed():
	main_container.visible = true
	party_container.visible = false
	shop_container.visible = false
	recruit_container.visible = false
	training_container.visible = false


func _on_begin_adventure_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_shop_button_pressed():
	shop_container.visible = true
	main_container.visible = false


func _on_recruit_button_pressed():
	recruit_container.visible = true
	main_container.visible = false


func _on_train_party_button_pressed():
	training_container.visible = true
	main_container.visible = false
