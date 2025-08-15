extends Panel

@onready var unit_health_bar_container = $MarginContainer/VBoxContainer/UnitHealthBarContainer
@onready var unit_combat_stat_container = $MarginContainer/VBoxContainer/UnitCombatStatContainer



var unit : Unit

func _ready():
	if unit:
		unit_health_bar_container.unit = unit
		unit_combat_stat_container.unit = unit
