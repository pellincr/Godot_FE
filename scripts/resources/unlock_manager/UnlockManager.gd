extends Resource

class_name UnlockManager

@export var archetypes_unlocked : Dictionary = {
	"armor_up" : true,
	"classic" : true,
	"healing_here" : true,
	"might_and_magic" : true,
	"mighty_mercs" : true,
	"random" : true,
	"swords" : true,
	"tavern_troop" : true,
	"vicious_vigilantes" : true
}

@export var commander_types_unlocked : Dictionary = {
	"centurion" : false,
	"destroyer" : false,
	"iron_viper" : true,
	"mage_knight" : false,
	"war_maiden" : false,
	"weapon_master": false
}

@export var unit_types_unlocked : Dictionary = {
	"archer" : true,
	"axe_armor" : true,
	"axe_cavalier" : true,
	"bishop" : true,
	"bladehand" : true,
	"brawler" : true,
	"corsair" : true,
	"crossbowman" : true,
	"duelist" : true,
	"field_medic" : true,
	"fighter" : true,
	"freewing" : true,
	"gunner" : true,
	"healer" : true,
	"lance_armor" : true,
	"lance_cavalier" : true,
	"lancer" : true,
	"marauder" : true,
	"monk" : true,
	"penitnet": true,
	"pikeman" : true,
	"runeblade" : true,
	"sanctioner" : true,
	"sea_witch" : true,
	"sellsword" : true,
	"sword_armor" : true,
	"sword_cavalier" : true,
	"thief" : true,
	"ward" : true,
	"vandal" : true
}

@export var items_unlocked : Dictionary = {
	"bolting" : true,
	"brass_knuckles" : true,
	"dark_pulse" : true,
	"dark_sword" : true,
	"devil_knuckles" : true,
	"enchanted_bow" : true,
	"enchanted_shotel" : true,
	"fiend_fire" : true,
	"fire_spell" : true,
	"great_bow" : true,
	"halberd" : true,
	"hand_axe" : true,
	"harm" : true,
	"heal_staff" : true,
	"iron_axe" : true,
	"iron_bow" : true,
	"iron_dagger" : true,
	"iron_lance" : true,
	"iron_shield" : true,
	"iron_sword" : true,
	"javelin" : true,
	"key" : true,
	"killer_bow" : true,
	"killer_lance" : true,
	"killer_sword" : true,
	"potion" : true,
	"rapier" : true,
	"sabre" : true,
	"sharp_claws" : true,
	"short_bow" : true,
	"silver_axe" : true,
	"silver_sword" : true,
	"smite" : true,
	"steel_axe" : true,
	"steel_lance" : true,
	"steel_sword" : true,
	"sword_reaver" : true,
	"warhammer" : true,
	"wind_blade" : true
}

func get_unlocked_count(dictionary : Dictionary):
	var count = 0
	var dict_keys = dictionary.keys()
	for key in dict_keys:
		if dictionary[key] == true:
			count += 1
	return count
