extends Control

@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


var reference_unit : Unit
var level_up_stat_array : Array[int] = []
var base_stat_array : Array[int] = []
var unit_icon : Texture
var unit_name : String
var unit_type : String
var unit_level : int

func _ready():
	update_level_up_stats()

func update_fields():
	update_sprite()
	update_level_up_stats()
	update_unit_type()
	update_unit_name()
	update_unit_level()

func set_unit(unit:Unit):
	self.reference_unit = unit
	set_unit_icon(self.reference_unit.map_sprite)
	set_base_stat_array(self.reference_unit.stats.to_array())
	var unit_type = UnitTypeDatabase.get_definition(self.reference_unit.unit_type_key)
	set_unit_type(unit_type.unit_type_name)
	set_unit_level(self.reference_unit.level)
	set_unit_name(self.reference_unit.name)

func set_unit_level(level: int):
	self.unit_level = level

func set_unit_name(name: String):
	self.unit_name = name
	
func set_unit_type(name :String):
	self.unit_type = name

func set_base_stat_array(base_stats: Array[int]):
	self.base_stat_array = base_stats

func set_level_up_stat_array(level_stats: Array[int]):
	self.level_up_stat_array = level_stats

func set_unit_icon(icon:Texture):
	self.unit_icon = icon

func update_sprite():
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/UnitSprite/UnitSprite2.texture = unit_icon
	$Panel/VBoxContainer/MarginContainer/HBoxContainer/UnitSprite.texture = unit_icon

func update_level_up_stats():
	animation_player.play("level_up")
	var children = $Panel/VBoxContainer/MarginContainer/HBoxContainer/CenterContainer/StatsGrid.get_children()
	for i in range(base_stat_array.size()):
		if i in range(children.size()):
			if children[i] is LevelUpAttributeContainer:
				children[i].set_ints(base_stat_array[i],level_up_stat_array[i])
				children[i].update_fields()
	for i in range(base_stat_array.size()):
		if i in range(children.size()):
			if level_up_stat_array[i] > 0:
				audio_stream_player.play()
				await children[i].update_level_up_bonus()
				#await children[i].animation_player.animation_finished


func update_unit_type(): 
	$Panel/VBoxContainer/Panel/HBoxContainer/MarginContainer2/HBoxContainer/UnitTypeLabel.text = unit_type
	
func update_unit_name():
	$Panel/VBoxContainer/Panel/HBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/UnitNameLabel.text = unit_name

func update_unit_level():
	$Panel/VBoxContainer/Panel/HBoxContainer/MarginContainer/HBoxContainer/LevelValueLabel.text = str(unit_level)
