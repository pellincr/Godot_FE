extends Panel
class_name UnitCombatExchangePreview

const UNIT_COMBAT_EXCHANGE_ARROW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_arrow.tscn")
#Attacking Unit
@onready var attacking_unit_header: PanelContainer = $HBoxContainer/LeftContainer/UnitCombatWeaponSelectionPanel
@onready var attacking_unit_stats: Panel = $HBoxContainer/LeftContainer/UnitCombatExchangeStatsPanel

#Defending Unit
@onready var defending_unit_header: PanelContainer = $HBoxContainer/RightContainer/UnitCombatWeaponSelectionPanel
@onready var defending_unit_stats: Panel = $HBoxContainer/RightContainer/UnitCombatExchangeStatsPanel


#Arrows & Combat visualization
@onready var arrow_container: VBoxContainer = $HBoxContainer/CenterContainer/ArrowContainer
#@onready var unit_combat_exchange_arrow: VBoxContainer = $HBoxContainer/CenterContainer/ArrowContainer/UnitCombatExchangeArrow

#Vars
#@export var attacking_unit: CombatUnit
#@export var defending_unit: CombatUnit

@export var targetting_resource : CombatMapUnitActionTargettingResource

@export var exchange_info: UnitCombatExchangeData


func set_exchange_info(ei:UnitCombatExchangeData):
	attacking_unit_header.set_unit = ei.attacker
	attacking_unit_stats.set
	defending_unit_header.set_unit = ei.defender

func set_all(ei:UnitCombatExchangeData):
	self.exchange_info = ei
	update_children()

func update_children():
	attacking_unit_header.set_unit(exchange_info.attacker.unit)
	attacking_unit_stats.set_all(exchange_info.attacker.stats.max_hp.evaluate(), exchange_info.attacker.unit.stats.hp, exchange_info.attacker_predicted_hp, exchange_info.attacker_net_damage, Constants.DAMAGE_TYPE.NONE, exchange_info.attacker_hit, exchange_info.attacker_critical)
	defending_unit_header.set_unit(exchange_info.defender.unit)
	defending_unit_stats.set_all(exchange_info.defender.stats.max_hp.evaluate(), exchange_info.defender.unit.stats.hp, exchange_info.defender_predicted_hp, exchange_info.defender_net_damage, Constants.DAMAGE_TYPE.NONE, exchange_info.defender_hit, exchange_info.defender_critical)
