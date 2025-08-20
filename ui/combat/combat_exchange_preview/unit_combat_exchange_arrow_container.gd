extends VBoxContainer

const UNIT_COMBAT_EXCHANGE_ARROW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_arrow.tscn")

@export var exchange_data : Array[UnitCombatExchangeTurnData] 
@export var attacker : CombatUnit
@export var defender : CombatUnit

func create_arrows():
	for turn in exchange_data:
		var unit_combat_exchange_arrow = UNIT_COMBAT_EXCHANGE_ARROW.instantiate()
		self.add_child(unit_combat_exchange_arrow)
		if turn.owner == attacker:
			unit_combat_exchange_arrow.populate(turn.attack_damage, turn.attack_count, turn.damage_type, false)
		elif turn.owner == defender:
			unit_combat_exchange_arrow.populate(turn.attack_damage, turn.attack_count, turn.damage_type, true)
		

func populate(a:CombatUnit, d:CombatUnit, ed: Array[UnitCombatExchangeTurnData] ):
	var children = self.get_children()
	for child in children:
		child.free()
	self.exchange_data = ed
	self.attacker = a
	self.defender = d
	create_arrows()
	
