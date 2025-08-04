extends Panel

signal campaign_selected(campaign)

@export var campaign : Campaign


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and has_focus():
		campaign_selected.emit(campaign)


func _on_mouse_entered():
	grab_focus()


func _on_focus_entered():
	theme = preload("res://overworld_new/campaign_selector_node_focused.tres")


func _on_focus_exited():
	theme = preload("res://overworld_new/campaign_selector_node_not_focused.tres")
