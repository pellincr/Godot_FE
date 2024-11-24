extends Node

enum States
{
	INIT,
	WEAPON_SELECT_IDLE,
	WEAPON_SELECT_CHANGED,
	TARGETING,
	TARGET_CHANGED,
	TRAGET_WEAPON_CHANGED,
	COMBAT_EXCHANGE,
	POST_COMBAT_EXCHANGE
}

enum INPUT
{
	
}

var state : States = States.INIT
var weapon : WeaponDefinition = null
var weapon_selected : bool = false
var actor : CombatUnit = null
var target : CombatUnit = null
var target_selected : bool = false
var input = null
var combat_exchange_complete : bool = false

func _process(delta: float) -> void: 
	#...
	pass


func set_state(new_state: int) -> void:
	var previous_state := state
	state = new_state
