extends Node

var config = ConfigFile.new()
var options_path := "user://options.cfg"

func save_options() -> void:
	config.save(options_path)

func load_options() -> void:
	var error = config.load(options_path)
	if error != OK:
		#if file doesn't exist, create the baseplate for a new one
		config.set_value("Audio","master_volume",5)
		config.set_value("Audio","music_volume",5)
		config.set_value("Audio","sfx_volume",5)
		config.save(options_path)
	#Set the Audio Players
	var master_volume = config.get_value("Audio","master_volume")
	var music_volume = config.get_value("Audio","music_volume")
	var sfx_volume = config.get_value("Audio","sfx_volume")
	if master_volume == 0:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)
		AudioServer.set_bus_volume_db(0,master_volume - 5)
	if music_volume == 0:
		AudioManager.music_player.volume_db = -80
	else:
		AudioManager.music_player.volume_db = music_volume - 20
	if sfx_volume == 0:
		AudioManager.sound_effect_player.volume_db = -80
	else:
		AudioManager.sound_effect_player.volume_db = music_volume - 20

func get_options_config_value(section: String, key : String):
	return config.get_value(section, key)

func set_options_config_value(section:String, key:String, value):
	config.set_value(section,key,value)
