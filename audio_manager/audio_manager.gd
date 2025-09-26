extends Node


#var active_music_stream : AudioStreamPlayer

@onready var clips: Node = $Clips
@onready var music_player: AudioStreamPlayer = $Clips/MusicPlayer
@onready var sound_effect_player: AudioStreamPlayer = $Clips/SoundEffectPlayer

var from_position := 0.0

func play(from_position:float = 0.0, skip_restart : bool = false) -> void:
	#active_music_stream = clips.get_node(audio_name)
	if skip_restart:
		return
	music_player.play(from_position)

func set_music_player_song(song):
	music_player.stream = song

func set_sound_effect_sound(sound):
	sound_effect_player.stream = sound
