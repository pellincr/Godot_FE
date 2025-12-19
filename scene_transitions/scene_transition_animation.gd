extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var upper_label = $ColorRect/VBoxContainer/UpperLabel
@onready var middle_label = $ColorRect/VBoxContainer/MiddleLabel
@onready var lower_label = $ColorRect/VBoxContainer/LowerLabel


func play_animation(animation:String):
	animation_player.play(animation)

func set_label_text(label, text):
	label.text = text

func set_upper_label_text(text):
	set_label_text(upper_label,text)

func set_middle_label_text(text):
	set_label_text(middle_label,text)

func set_lower_label_text(text):
	set_label_text(lower_label,text)


func transition_in_animation(parent_node):
	#var scene_transition = SceneTransitionAnimation.instantiate()
	parent_node.add_child(self)
	play_animation("fade_out")
	await get_tree().create_timer(.5).timeout
	queue_free()

func transition_out_animation(parent_node):
	#var scene_transition = SceneTransitionAnimation.instantiate()
	parent_node.add_child(self)
	play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout
