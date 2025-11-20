extends Control



@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_animation(animation):
	animation_player.play(animation)
