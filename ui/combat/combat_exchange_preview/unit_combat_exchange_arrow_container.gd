extends VBoxContainer

const UNIT_COMBAT_EXCHANGE_ARROW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_arrow.tscn")

@export var combat_exchange_data : Array[UnitCombatExchangeTurnData] 
@export var support_exchange_data : Array[UnitSupportExchangeTurnData] 
@export var attacker : CombatUnit
@export var defender : CombatUnit

func create_arrows_combat():
	for turn in combat_exchange_data:
		var unit_combat_exchange_arrow = UNIT_COMBAT_EXCHANGE_ARROW.instantiate()
		self.add_child(unit_combat_exchange_arrow)
		if turn.owner == attacker:
			unit_combat_exchange_arrow.populate(turn.attack_damage, turn.attack_count, turn.damage_type, false)
		elif turn.owner == defender:
			unit_combat_exchange_arrow.populate(turn.attack_damage, turn.attack_count, turn.damage_type, true)

func create_arrows_support():
	for turn in support_exchange_data:
		var unit_combat_exchange_arrow = UNIT_COMBAT_EXCHANGE_ARROW.instantiate()
		self.add_child(unit_combat_exchange_arrow)
		unit_combat_exchange_arrow.populate(turn.effect_weight, turn.attack_count)

func populate_combat(a:CombatUnit, d:CombatUnit, ed: Array[UnitCombatExchangeTurnData] ):
	var children = self.get_children()
	for child in children:
		child.free()
	self.combat_exchange_data = ed
	self.attacker = a
	self.defender = d
	create_arrows_combat()

func populate_support(a:CombatUnit, d:CombatUnit, ed: Array[UnitSupportExchangeTurnData]):
	var children = self.get_children()
	for child in children:
		child.free()
	self.support_exchange_data = ed
	self.attacker = a
	self.defender = d
	create_arrows_support()
	
