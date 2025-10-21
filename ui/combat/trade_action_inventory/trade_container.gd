extends Control
class_name TradeContainer

signal external_trade_completed

var unit_a : Unit
var unit_b : Unit

@onready var unit_a_icon: TextureRect = $UnitIconHboxContainer/UnitAIcon
@onready var unit_b_icon: TextureRect = $UnitIconHboxContainer/UnitBIcon

@onready var trade_unit_inventory_a: TradeUnitInventory = $TradeUnitInventoryHboxContainer/TradeUnitInventorya
@onready var trade_unit_inventory_b: TradeUnitInventory = $TradeUnitInventoryHboxContainer/TradeUnitInventoryb

@onready var equippable_item_information: EquippableItemInformation = $ItemInfoBackgroundPanel/ItemInfoContainer/Equippable_item_information
@onready var description_body: Label = $ItemInfoBackgroundPanel/ItemInfoContainer/DescriptionBody

var currently_selected_item : ItemDefinition
var currently_selected_item_owner : Unit

func _ready(): 
	trade_unit_inventory_a.connect("item_selected", item_selected)
	trade_unit_inventory_a.connect("item_hovered", item_hovered)
	trade_unit_inventory_b.connect("item_selected", item_selected)
	trade_unit_inventory_b.connect("item_hovered", item_hovered)

func populate(trader: CombatUnit, target: CombatUnit):
	set_unit_a(trader.unit)
	set_unit_b(target.unit)

static func create(ua : Unit, ub :Unit) -> TradeContainer:
	var trade_container = TradeContainer.new()
	trade_container.set_unit_a(ua)
	trade_container.set_unit_b(ub)
	trade_container.update_trade_inventories()
	return trade_container

func update_trade_inventories():
	update_trade_inventory_a(unit_a)
	update_trade_inventory_b(unit_b)

func update_trade_inventory_a(ua: Unit):
	trade_unit_inventory_a.set_unit(ua)
	trade_unit_inventory_a.update_fields()

func update_trade_inventory_b(ub: Unit):
	trade_unit_inventory_b.set_unit(ub)
	trade_unit_inventory_b.update_fields()

func set_unit_a(ua: Unit):
	self.unit_a = ua
	update_trade_inventory_a(unit_a)
	update_unit_a_icon(unit_a.icon)

func set_unit_b(ub: Unit):
	self.unit_b = ub
	update_trade_inventory_b(unit_b)
	update_unit_b_icon(unit_b.icon)

func item_hovered(item: ItemDefinition): # A NICE TO HAVE
	pass

func item_selected(item: ItemDefinition, index: int, item_owner: Unit):
	if currently_selected_item_owner:
		if currently_selected_item_owner == item_owner:
			if currently_selected_item != item:
				item_owner.inventory.swap_at_indexes(item_owner.inventory.get_item_index(item), item_owner.inventory.get_item_index(currently_selected_item))
		else:
			perform_trade(item_owner, item, currently_selected_item_owner, currently_selected_item)
		update_trade_inventories()
		trade_unit_inventory_a.reset_btns()
		trade_unit_inventory_b.reset_btns()
		currently_selected_item = null
		currently_selected_item_owner = null
		#attempt to equip front item in the units inventory
		unit_a.attempt_to_equip_front_item()
		unit_b.attempt_to_equip_front_item()
	else: 
		currently_selected_item = item
		currently_selected_item_owner = item_owner

func perform_trade(unit_a:Unit, item_a:ItemDefinition, unit_b:Unit, item_b:ItemDefinition):
	#print("performing trade with : "+ item_a.name + " | " + item_b.name)
	var a_index = unit_a.inventory.get_item_index(item_a)
	var b_index = unit_b.inventory.get_item_index(item_b)
	if (a_index >= 0): 
		if (b_index >= 0):
			unit_a.inventory.replace_item_at_index(a_index, item_b)
			unit_b.inventory.replace_item_at_index(b_index, item_a)
		else: #a exists b does not
			unit_b.inventory.give_item(item_a)
			unit_a.inventory.discard_item(item_a)
	else:
		if (b_index >= 0): # item_a is null? 
			unit_a.inventory.give_item(item_b)
			unit_b.inventory.discard_item(item_b) 
		pass 
	#A CROSS UNIT TRADE HAS BEEN COMPLETED, EXPEND MINOR ACTION
	external_trade_completed.emit()

func grab_focus_unit_a():
	trade_unit_inventory_a.grab_primary_btn_focus()

func update_unit_a_icon(texture: Texture2D):
	unit_a_icon.texture = texture

func update_unit_b_icon(texture: Texture2D):
	unit_b_icon.texture = texture
