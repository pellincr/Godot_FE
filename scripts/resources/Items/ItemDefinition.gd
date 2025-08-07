extends Resource
class_name ItemDefinition

enum ITEM_TYPE {
	WEAPON,
	STAFF,
	USEABLE_ITEM,
	EQUIPMENT_LOOT
}

@export_group("Item Info")
@export var name = ""
@export var db_key = ""
@export var equippable = false
@export var description : String
@export_enum("Weapon", "Staff", "Usable Item", "Equipment or Loot" ) var item_type :int = 0

@export var rarity : ItemRarity

@export_subgroup("Item Stats")
@export_range(-1, 100, 1, "or_greater") var uses = 1
@export_range(1, 2, 1, "or_greater") var max_uses = 1

@export_range(0,1000,1, "or_greater") var worth = 100
var price : int = calculate_price()

@export_group("Visuals")
@export var icon: Texture2D


func use():
	#Do something
	print(name + " was used!")
	uses = uses - 1
	print(str(uses) + " uses remain")
	if uses == 0:
		print(name + " broke!")

func calculate_price():
	return floor(worth * (uses / max_uses))
