extends Resource

class_name UnlockManager

@export var archetypes_unlocked : Dictionary 
"""= {
	"armor_up" : true,
	"bows" : true,
	"classic" : true,
	"dark_development" : true,
	"daring_daggers" : true,
	"fearless_fist" : true,
	"healing_here" : true,
	"kingdom_come" : true,
	"lively_lances" : true,
	"magic_mania" : true,
	"might_and_magic" : true,
	"mighty_mercs" : true,
	"mundane_many" : true,
	"random" : true,
	"swords" : true,
	"vicious_vigilantes" : true
}"""

@export var commander_types_unlocked : Dictionary
"""= {
	"drengr" : true,
	"iron_viper" : true,
	"line_breaker" : true,
	"mage_knight" : true,
	"night_blade" : true
}
"""
@export var unit_types_unlocked : Dictionary 
"""= {
	"archer" : true,
	"axe_armor" : true,
	"axe_cavalier" : true,
	"bishop" : true,
	"bladehand" : true,
	"bow_armor" : true,
	"brawler" : true,
	"bulwark": true,
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
	"magewing" :true,
	"marauder" : true,
	"monk" : true,
	"penitent": true,
	"pikeman" : true,
	"purge_armor" : true,
	"runeblade" : true,
	"sanctioner" : true,
	"sea_witch" : true,
	"sellsword" : true,
	"shaman" : true,
	"squire" : true,
	"suncaster" : true,
	"sword_armor" : true,
	"sword_cavalier" : true,
	"thief" : true,
	"troubadour" : true,
	"ward" : true,
	"vandal" : true,
	"farmhand" : true,
	"hewman" : true,
	"apprentice" : true,
	"twigshot" : true,
	"chopper": true,
	"knave" : true
}
"""

@export var items_unlocked : Dictionary 
"""= {
	"abyss_typhoon": true,
	"all_seeing_hands": true,
	"annihilate": true,
	"bastion_crab" : true,
	"bolting" : true,
	"boost_bread" : true,
	"brass_knuckles" : true,
	"brawn_prawn" : true,
	"brutvine_heartroot" : true,
	"brutvine_sap" : true,
	"cave_carrot" : true,
	"century_cheese" : true,
	"chest_key" : true,
	"colossus" : true,
	"dark_pulse" : true,
	"dark_sword" : true,
	"deliverance": true,
	"devil_knuckles" : true,
	"elixir": true,
	"enchanted_bow" : true,
	"enchanted_shotel" : true,
	"evil_eye" : true,
	"eye_greatshield" : true,
	"fiend_fire" : true,
	"finesse_fillet" : true,
	"fire_spell" : true,
	"giants_brew" : true,
	"godseed_oil" : true,
	"gold_coins_large" : true,
	"gold_coins_small" : true,
	"gold_coins_medium" : true,
	"great_axe" : true,
	"great_bow" : true,
	"great_sword" : true,
	"halberd" : true,
	"hand_axe" : true,
	"harm" : true,
	"hastehawk_feather" : true,
	"hatchet" : true,
	"hawkweed" : true,
	"heal_staff" : true,
	"heartbeet" : true,
	"heavy_lance" : true,
	"heavy_knife" : true,
	"holy_fire" : true,
	"imbue_staff" : true,
	"infused_obsidian" : true,
	"iron_axe" : true,
	"iron_bow" : true,
	"iron_dagger" : true,
	"iron_lance" : true,
	"iron_shield" : true,
	"iron_sword" : true,
	"javelin" : true,
	"knife" : true,
	"killer_axe" : true,
	"killer_bow" : true,
	"killer_dagger" : true,
	"killer_fist" : true,
	"killer_lance" : true,
	"killer_sword" : true,
	"kukri" : true,
	"life_tap" : true,
	"long_bow" : true,
	"lumen" : true,
	"mage_blade" : true,
	"mandate" : true,
	"martial_scroll" : true,
	"minor_heal": true,
	"moonclam_pearl": true,
	"oak_wood_charm": false, #Unique?
	"percise_pepper": true, 
	"pilum" : true,
	"potion" : true,
	"power_rune" : true,
	"ray" : true,
	"rapier" : true,
	"recover": true,
	"reinforced_bow" : true,
	"resonant_ore" : true, #Unique?
	"runewart" : true,
	"rushraddish" : true,
	"sabre" : true,
	"sanctree_branch" : true,
	"sanctuary_shell" : true,
	"sanguis" : true,
	"shade" : true,
	"sharp_claws" : true,
	"short_axe" : true,
	"short_bow" : true,
	"short_sword" : true,	
	"silver_axe" : true,
	"silver_bow" : true,
	"silver_dagger" : true,
	"silver_fist" : true,
	"silver_lance" : true,
	"silver_shield" : true,
	"silver_sword" : true,
	"slim_axe" : true,
	"slim_lance" : true,
	"smite" : true,
	"soul_rip" : true,
	"spear" : true,
	"spirit_dagger" : true,
	"spirit_ink" : true,
	"steel_axe" : true,
	"steel_bow" : true,
	"steel_dagger" : true,
	"steel_fist" : true,
	"steel_lance" : true,
	"steel_shield" : true,
	"steel_sword" : true,
	"stonebark_blossom" : true,
	"stonebark_essence" : true,
	"stonedragon_tail" : true,
	"swift_shellfish" : true,
	"sword_reaver" : true,
	"tempo_tonic" : true,
	"titan_trout" : true,
	"titans_will" : true,
	"tomahawk" : true,
	"torrent" : true,
	"vermillion_tonic" : true,
	"warding_worm" : true,
	"warhammer" : true,
	"wind" : true,
	"wisdom_wine" : true,
	"wyvern_wingdust" : true,
	"refillable_potion" : true,
	"large_potion" : true,
	"zweihander" : true,
	"valor_axe" : true,
	"valor_bow" : true,
	"valor_dagger" : true,
	"valor_lance" : true,
	"valor_blade" : true,
	"tri_axe" : true,
	"tri_pike" : true,
	"tri_edge" : true,
	"armorbreaker" : true,
	"shotel" : true,
	"iron_greatshield" : true,
	"steel_greatshield" : true,
	"silver_greatshield" : true,
}
"""

func _init() -> void:
	instantiate_archetypes_unlocked()
	instantiate_commander_types_unlocked()
	instantiate_unit_types_unlocked()
	instantiate_items_unlocked()


func instantiate_archetypes_unlocked():
	var archetypes := ArmyArchetypeDatabase.army_archetypes.values()
	for archetype : ArmyArchetypeDefinition in archetypes:
		archetypes_unlocked[archetype] = archetype.unlocked

func instantiate_unit_types_unlocked():
	var unit_types = UnitTypeDatabase.unit_types.values()
	for unit_type : UnitTypeDefinition in unit_types:
		unit_types_unlocked[unit_type] = unit_type.unlocked

func instantiate_commander_types_unlocked():
	var commander_types = UnitTypeDatabase.commander_types.values()
	for commander_type : CommanderDefinition in commander_types:
		commander_types_unlocked[commander_type] = commander_type.unlocked

func instantiate_items_unlocked():
	var items = ItemDatabase.items.values()
	for item: ItemDefinition in items:
		items_unlocked[item] = item.unlocked

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
