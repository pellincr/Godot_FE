extends Resource
class_name LootTableEntry

@export var probability : float
#@export var unique : bool
#@export var always : bool
#var enabled : bool
@export_group("Item Information")
@export var item_db_key: String #LEAVE 0 to use random
@export var item_rarity_whitelist : Array[String]
@export var item_type_whitelist : Array[ItemDefinition.ITEM_TYPE]
@export var weapon_type_whitelist : Array[itemConstants.WEAPON_TYPE] #ONLY USED IF WHITELIST HAS WEAPON
