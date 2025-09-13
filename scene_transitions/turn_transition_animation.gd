extends Node2D

@onready var texture_rect = $TextureRect

@onready var animation_player = $AnimationPlayer

@onready var label = $TextureRect/Label


func play_animation(animation:String):
	animation_player.play(animation)
	

func set_label(text):
	label.text = text


func set_texture_hue(front_color):
	var gradient :GradientTexture2D= texture_rect.texture
	gradient.gradient.set_color(0,front_color)
