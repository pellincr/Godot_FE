extends Resource

class_name UnlockManager

@export var archetypes_unlocked : Dictionary = {
	"armor_up" : true,
	"bows" : true,
	"classic" : true,
	"dark_development" : true,
	"healing_here" : true,
	"might_and_magic" : true,
	"mighty_mercs" : true,
	"random" : true,
	"swords" : true,
	"taverns_troop" : true,
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
	"hakkapel" : true,
	"healer" : true,
	"lance_armor" : true,
	"lance_cavalier" : true,
	"lancer" : true,
	"mage" : true,
	"marauder" : true,
	"monk" : true,
	"penitent": true,
	"pikeman" : true,
	"runeblade" : true,
	"sanctioner" : true,
	"sea_witch" : true,
	"shaman" : true,
	"sellsword" : true,
	"sword_armor" : true,
	"sword_cavalier" : true,
	"thief" : true,
	"troubadour" : true,
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
	"evil_eye" : true,
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
	"kukri" : true,
	"life_tap" : true,
	"potion" : true,
	"rapier" : true,
	"sabre" : true,
	"sharp_claws" : true,
	"short_bow" : true,
	"silver_axe" : true,
	"silver_sword" : true,
	"smite" : true,
	"soul_rip" : true,
	"steel_axe" : true,
	"steel_lance" : true,
	"steel_sword" : true,
	"sword_reaver" : true,
	"warhammer" : true,
	"wind_blade" : true
}

func get_count(dict: Dictionary, locked : bool):
	var count = 0
	var dict_keys = dict.keys()
	for key in dict_keys:
		if dict[key] == locked:
			count += 1
	return count

func get_unlocked_count(dict : Dictionary):
	return get_count(dict,true)

func get_locked_count(dict : Dictionary):
	return get_count(dict,false)

func get_individual_unlocked_percentage(dict: Dictionary):
	var unlocked_count = get_unlocked_count(dict)
	#var locked_count = get_locked_count(dict)
	var total = dict.size()
	var percent = float(unlocked_count)/total *100
	return floor(percent)

func get_total_unlocked_percentage():
	var archetypes_unlocked_percent = get_individual_unlocked_percentage(archetypes_unlocked)
	var commander_types_unlocked_percent = get_individual_unlocked_percentage(commander_types_unlocked)
	var unit_types_unlocked_percent = get_individual_unlocked_percentage(unit_types_unlocked)
	var items_unlocked_percent = get_individual_unlocked_percentage(items_unlocked)
	var total_unlocked = archetypes_unlocked_percent + commander_types_unlocked_percent + unit_types_unlocked_percent + items_unlocked_percent
	var percent = float(total_unlocked)/400*100
	return floor(percent)
