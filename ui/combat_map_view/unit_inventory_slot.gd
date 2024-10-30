extends Control

class_name UnitInventorySlot

var reference_item : ItemDefinition
var equipped : bool

func update_item_fields():
	check_if_item()
	if reference_item :
		$Button.icon = reference_item.icon
		$Button.text = reference_item.name
		$InfoMargin/Uses.text = str(reference_item.uses)

func set_equipped(is_equipped: bool) :
	$EquippedMargin.visible = is_equipped
	self.equipped = is_equipped

func update_equipped() :
	$EquippedMargin.visible = equipped

func set_reference_item(item: ItemDefinition) :
	self.reference_item = item
	update_item_fields()
	
func update_all():
	update_item_fields()
	update_equipped()
	
func create(item:ItemDefinition, e:bool = false) -> UnitInventorySlot:
	var unit_inv_slot = UnitInventorySlot.new()
	unit_inv_slot.set_reference_item(item)
	unit_inv_slot.set_equipped(e)
	return unit_inv_slot
	
func set_all(item:ItemDefinition, e:bool = false) :
	set_reference_item(item)
	set_equipped(e)

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	pass
	
func check_if_item():
	if(reference_item) :
		self.visible =  true
	else :
		self.visible =  false	
