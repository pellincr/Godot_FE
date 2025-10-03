extends Node


#var active_music_stream : AudioStreamPlayer

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sound_effect_player: AudioStreamPlayer = $SoundEffectPlayer

@export var main_music_library : AudioLibrary
@export var main_sound_effect_library : AudioLibrary
#Sound Effects

var from_position := 0.0

func get_music_library_song(key:String):
	return main_music_library.sounds.get(key)

func get_sound_effect_library_sound(key:String):
	return main_sound_effect_library.sounds.get(key)

func play_sound_effect(key:String)-> void:
	if key:
		var sound_effect_stream = get_sound_effect_library_sound(key)
		if !sound_effect_player.playing: sound_effect_player.play()
		
		var polyphonic_stream_playback := sound_effect_player.get_stream_playback()
		polyphonic_stream_playback.play_stream(sound_effect_stream)
	else:
		printerr("no tag provided, cannot play sound effect")

func stop_sound_effect() -> void:
	sound_effect_player.stop()

func tween_sound_effect_pitch(final_val, duration, delay_time:int = 0):
	var tween : Tween = create_tween()
	var og_pitch = sound_effect_player.pitch_scale
	tween.tween_property(sound_effect_player,"pitch_scale",final_val,duration).set_delay(delay_time)
	sound_effect_player.pitch_scale = og_pitch

func play_music(key:String)-> void:
	if key:
		var music_stream = get_music_library_song(key)
		var current_stream = music_player.stream
		
		if music_stream != current_stream:
			
			music_player.stream = music_stream
			
			music_player.play()

func stop_music() -> void:
	music_player.stop()

#func play_music(from_position:float = 0.0, skip_restart : bool = false) -> void:
#	#active_music_stream = clips.get_node(audio_name)
#	if skip_restart:
#		return
#	music_player.play(from_position)

func set_music_player_song(song):
	music_player.stream = song

func set_sound_effect_sound(sound):
	sound_effect_player.stream = sound


func get_music_stream():
	return music_player.stream
