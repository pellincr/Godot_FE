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
