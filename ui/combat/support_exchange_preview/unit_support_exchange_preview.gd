extends Panel
class_name UnitSupportExchangePreview

const UNIT_COMBAT_EXCHANGE_ARROW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_arrow.tscn")
# Suporting Unit
@onready var supporting_unit_header: PanelContainer = $HBoxContainer/LeftContainer/UnitCombatWeaponSelectionPanel
@onready var supporting_unit_stats: PanelContainer = $HBoxContainer/LeftContainer/UnitCombatExchangeStatsPanel

# Target Unit
@onready var target_unit_header: PanelContainer = $HBoxContainer/RightContainer/UnitCombatWeaponSelectionPanel
@onready var target_unit_stats: PanelContainer = $HBoxContainer/RightContainer/UnitCombatExchangeStatsPanel


#Arrows & Combat visualization
@onready var arrow_container: VBoxContainer = $HBoxContainer/CenterContainer/ArrowContainer
#@onready var unit_combat_exchange_arrow: VBoxContainer = $HBoxContainer/CenterContainer/ArrowContainer/UnitCombatExchangeArrow

#Vars
@export var weapon_swap_enabled: bool 
@export var exchange_info: UnitSupportExchangeData

func set_all(ei:UnitSupportExchangeData, wse:bool):
	self.weapon_swap_enabled = wse
	self.exchange_info = ei
	update_children()

func update_children():
	supporting_unit_header.set_all(exchange_info.supporter, weapon_swap_enabled)
	supporting_unit_stats.set_all(exchange_info.supporter.get_max_hp(), exchange_info.supporter.current_hp, exchange_info.supporter.current_hp, exchange_info.supporter_net_heal, Constants.DAMAGE_TYPE.NONE, 100, 0)
	target_unit_header.set_all(exchange_info.target, false)
	target_unit_stats.set_all(exchange_info.target.get_max_hp(), exchange_info.target.current_hp, exchange_info.target_predicted_hp, 0, Constants.DAMAGE_TYPE.NONE, 0,0)
	arrow_container.populate_support(exchange_info.supporter, exchange_info.target, exchange_info.exchange_data)
