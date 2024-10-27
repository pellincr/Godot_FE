extends Resource

class_name CombatUnit

enum Group
{
	PLAYERS,
	ENEMIES,
	FRIENDLY,
	NOMAD
}

var alive : bool
var turn_taken : bool
var unit : Unit
var action_list :  Array[String]
var map_position : Vector2i
var skill_list = ["attack_melee"]
var map_display : Control

var allegience : int



static func create(unit: Unit) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	##instance.map_position = position
	##instance.allegience = group
	return instance
