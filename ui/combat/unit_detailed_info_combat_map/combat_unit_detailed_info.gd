extends PanelContainer

var combatUnit: CombatUnit

@onready var unit_detailed_info: UnitDetailedInfo = $UnitDetailedInfo

#func _init(combat_unit: CombatUnit) -> void:
	#combatUnit = combat_unit

func _ready() -> void:
	if combatUnit != null:
		unit_detailed_info.unit = combatUnit.unit
		unit_detailed_info.update_by_unit()

func set_combat_unit(combat_unit: CombatUnit):
	combatUnit = combat_unit
	update_by_combat_unit()

func update_by_combat_unit():
	if combatUnit != null:
		unit_detailed_info.unit = combatUnit.unit
		unit_detailed_info.update_by_unit()
