extends PanelContainer

var combatUnit: CombatUnit

@onready var unit_detailed_info: UnitDetailedInfo = $UnitDetailedInfo

#func _init(combat_unit: CombatUnit) -> void:
	#combatUnit = combat_unit

func _ready() -> void:
	if combatUnit != null:
		unit_detailed_info.unit = combatUnit.unit
		unit_detailed_info.set_block_item_use(true)
		unit_detailed_info.update_by_unit()

func set_combat_unit(combat_unit: CombatUnit):
	combatUnit = combat_unit
	update_by_combat_unit()
	unit_detailed_info.set_block_item_use(true)

func update_by_combat_unit():
	if combatUnit != null:
		unit_detailed_info.clear_item_info_container()
		unit_detailed_info.unit = combatUnit.unit
		unit_detailed_info.update_by_unit()
		get_viewport().gui_release_focus()
		unit_detailed_info.unit_inventory_container.grab_first_slot_focus()

func grab_inventory_focus():
	unit_detailed_info.unit_inventory_container.grab_first_slot_focus()
	
