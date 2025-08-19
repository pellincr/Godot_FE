extends Panel

@onready var unit_health_bar_container = $MarginContainer/VBoxContainer/UnitHealthBarContainer
@onready var unit_combat_stat_container = $MarginContainer/VBoxContainer/UnitCombatStatContainer


@export var max_health: int = 0
@export var current_health: int = 0
@export var predicted_health: int = 0

@export var dmg :int 
@export var damage_type : Constants.DAMAGE_TYPE 
@export var hit :int 
@export var crit :int 

func set_all(mh: int, ch: int, ph: int, dmg:int, dt: Constants.DAMAGE_TYPE, h: int, c: int):
	self.max_health = mh
	self.current_health = ch
	self.predicted_health = ph

	self.dmg = dmg
	self.damage_type = dt
	self.hit = h
	self.crit = c
	update()

func update():
	unit_health_bar_container.set_all(max_health, current_health, predicted_health)
	unit_combat_stat_container.set_all(dmg, damage_type, hit, crit)
