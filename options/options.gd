extends Control

class_name Options

signal menu_closed()

@onready var option_type_container: VBoxContainer = $PanelContainer/MarginContainer/OptionTypeContainer
@onready var audio_container: VBoxContainer = $PanelContainer/MarginContainer/AudioContainer


@onready var video_button: GeneralMenuButton = $PanelContainer/MarginContainer/OptionTypeContainer/VideoButton

@onready var master_volume_slider: HSlider = $PanelContainer/MarginContainer/AudioContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $PanelContainer/MarginContainer/AudioContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $PanelContainer/MarginContainer/AudioContainer/SFXVolumeContainer/SFXVolumeSlider


@onready var master_volume_value_label: Label = $PanelContainer/MarginContainer/AudioContainer/MasterVolumeContainer/MasterVolumeValueLabel
@onready var music_volume_value_label: Label = $PanelContainer/MarginContainer/AudioContainer/MusicVolumeContainer/MusicVolumeValueLabel
@onready var sfx_volume_value_label: Label = $PanelContainer/MarginContainer/AudioContainer/SFXVolumeContainer/SFXVolumeValueLabel



enum STATE{
	NONE, VIDEO, AUDIO, GAMEPLAY
}

var current_state := STATE.NONE

func _ready() -> void:
	video_button.grab_focus()	
	#OptionsConfig.load_options()
	#Set Volume Sliders
	#var current_master_volume := AudioServer.get_bus_volume_db(0) + 5
	var current_master_volume = OptionsConfig.get_options_config_value("Audio","master_volume")
	set_label_text(master_volume_value_label, str(current_master_volume))
	set_slider_value(master_volume_slider,current_master_volume)
	#var current_music_volume := AudioManager.music_player.volume_db + 20
	var current_music_volume = OptionsConfig.get_options_config_value("Audio","music_volume")
	set_label_text(music_volume_value_label, str(current_music_volume))
	set_slider_value(music_volume_slider,current_music_volume)
	#var current_sfx_volume := AudioManager.sound_effect_player.volume_db + 20
	var current_sfx_volume = OptionsConfig.get_options_config_value("Audio","sfx_volume")
	set_label_text(sfx_volume_value_label, str(current_sfx_volume))
	set_slider_value(sfx_volume_slider,current_sfx_volume)
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		match current_state:
			STATE.NONE:
				queue_free()
				menu_closed.emit()
			_:
				set_current_state(STATE.NONE)


func set_label_text(label:Label, text:String):
	label.text = text

func set_slider_value(slider:HSlider, value:float):
	slider.value = value

func update_by_state():
	match current_state:
		STATE.NONE:
			video_button.grab_focus()
			option_type_container.visible = true
			audio_container.visible = false
		STATE.VIDEO:
			pass
		STATE.AUDIO:
			master_volume_slider.grab_focus()
			option_type_container.visible = false
			audio_container.visible = true
		STATE.GAMEPLAY:
			pass


func set_current_state(state:STATE):
	current_state = state
	update_by_state()


func _on_video_button_pressed() -> void:
	set_current_state(STATE.VIDEO)

func _on_audio_button_pressed() -> void:
	set_current_state(STATE.AUDIO)


func _on_gameplay_button_pressed() -> void:
	set_current_state(STATE.GAMEPLAY)



func _on_master_volume_slider_value_changed(value: float) -> void:
	var volume = value - 5
	AudioManager.play_sound_effect("menu_cursor")
	set_label_text(master_volume_value_label, str(int(value)))
	print("Set Volume to:" + str(volume))
	if value == 0:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)
		AudioServer.set_bus_volume_db(0,volume)
	#Set and Save the config file
	OptionsConfig.set_options_config_value("Audio","master_volume",value)
	OptionsConfig.save_options()


func _on_music_volume_slider_value_changed(value: float) -> void:
	var volume = value - 20
	AudioManager.play_sound_effect("menu_cursor")
	set_label_text(music_volume_value_label, str(int(value)))
	if value == 0:
		AudioManager.music_player.volume_db = -80
	else:
		AudioManager.music_player.volume_db = volume
	#Set and Save the Config File
	OptionsConfig.set_options_config_value("Audio","music_volume",value)
	OptionsConfig.save_options()



func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var volume = value - 20
	AudioManager.play_sound_effect("menu_cursor")
	set_label_text(sfx_volume_value_label, str(int(value)))
	if value == 0:
		AudioManager.sound_effect_player.volume_db = -80
	else:
		AudioManager.sound_effect_player.volume_db = volume
	OptionsConfig.set_options_config_value("Audio","sfx_volume",value)
	OptionsConfig.save_options()


func _on_volume_slider_focus_entered() -> void:
	AudioManager.play_sound_effect("menu_cursor")
