extends Control

class_name AttackActionInventory

var selected_item: ItemDefinition
var combat_unit: CombatUnit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func create(ca: CombatUnit) -> AttackActionInventory: 
	var a_a_inv = AttackActionInventory.new()
	a_a_inv.set_unit(ca)
	return a_a_inv

func set_unit(cu: CombatUnit):
	self.combat_unit = cu
	set_inventory_slots()

func move_to_target_selection(postion: Vector2i, range: Array[int]):
	#update unit currently equipped to the button's data
	pass
	
func set_inventory_slots():
	var slot1 = UnitInventorySlot.new()
	slot1.set_all(combat_unit.unit.inventory.equipped, true)
	$MarginContainer/VBoxContainer.add_child(slot1)
	for item in combat_unit.unit.inventory.items: 
		if item.equippable:
			var extra_slot = UnitInventorySlot.new()
			extra_slot.set_all(item)
			$MarginContainer/VBoxContainer.add_child(extra_slot)
	
