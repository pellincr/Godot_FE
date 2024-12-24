extends Control

class_name UnitInventorySlot

signal btn_entered(item: ItemDefinition)

@export var reference_item : ItemDefinition
var equipped : bool

func get_button() -> Button:
	return $Button

func update_item_fields():
	##check_if_item()
	if reference_item :
		$Button.icon = reference_item.icon
		$Button.text = reference_item.name
		$InfoMargin/Uses.text = str(reference_item.uses)
	else : 
		$Button.icon = null
		$Button.text = ""
		$InfoMargin/Uses.text = ""
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
	
func mouse_entered():
	emit_signal("btn_entered", reference_item )
	
func check_if_item():
	if(reference_item) :
		self.visible =  true
	else :
		self.visible =  false	


func show_options(item:ItemDefinition):
	$OptionsContainer.visible = true
	if item is WeaponDefinition:
		$OptionsContainer/Panel/VBoxContainer/Button1.text = "Equip"
	else :
		$OptionsContainer/Panel/VBoxContainer/Button1.text = "Use"
	$OptionsContainer/Panel/VBoxContainer/Button2.text = "Discard"
