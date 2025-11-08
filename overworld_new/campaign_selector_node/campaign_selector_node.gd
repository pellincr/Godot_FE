extends Panel

signal campaign_selected(campaign)

@export var campaign : Campaign
@onready var campaign_name_label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	if campaign:
		set_campaign_name_label(campaign.name)




func set_campaign_name_label(c_name):
	campaign_name_label.text = c_name


func _on_mouse_entered():
	grab_focus()


func _on_focus_entered():
	AudioManager.play_sound_effect("menu_cursor")
	theme = preload("res://overworld_new/campaign_selector_node/campaign_selector_node_focused.tres")
	var campaign_preview = preload("res://overworld_new/campaign_preview/campaign_preview.tscn").instantiate()
	campaign_preview.campaign = campaign
	add_child(campaign_preview)
	campaign_preview.position = Vector2(72,-24)


func _on_focus_exited():
	theme = preload("res://overworld_new/campaign_selector_node/campaign_selector_node_not_focused.tres")
	get_child(-1).queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		AudioManager.play_sound_effect("menu_confirm")
		campaign_selected.emit(campaign)
