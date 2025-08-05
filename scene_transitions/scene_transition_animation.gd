extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var label = $ColorRect/Label

func play_animation(animation:String):
	animation_player.play(animation)

func set_label_text(text):
	label.text = text
