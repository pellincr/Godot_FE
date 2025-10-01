extends Resource

class_name EventOption

enum EVENT_EFFECT{
	NONE,
	CHANGE_RANDOM_UNIT_STATS,
	CHANGE_TARGET_UNIT_STATS,
	CHANGE_ALL_UNIT_STATS,
	CHANGE_COMMANDER_UNIT_STATS,
	CHANGE_RANDOM_WEAPON_STATS,
	CHANGE_TARGET_WEAPON_STATS,
	CHANGE_COMMANDER_WEAPON_STATS,
	GIVE_ITEM,
	GIVE_EXPERIENCE,
	RECRUIT_UNIT, # TO BE IMPL
	MINOR_BATTLE, # TO BE IMPL
	##OLD SPECIFIC OR SPECIAL
	STRENGTH_ALL,
	MAGIC_ALL,
	RANDOM_WEAPON,
	RANDOM_CONSUMABLE,
	FLEE,
	BANDIT_BRIBE,
	BANDIT_FIGHT,
	BANDIT_INTIMIDATE,
	TRIAL_MEDITATE,
	TRIAL_CUT_PATH,
	TRIAL_RUSH_THROUGH,
	GOBLET_DRINK,
	GOBLET_SPILL,
}
@export var title : String
@export var description : String
@export var effect : EVENT_EFFECT
@export var gold_change = 0

@export_group("Unit Stat Change Data")
@export var unit_stat_change : UnitStat = UnitStat.new()
@export var unit_growth_change : UnitStat = UnitStat.new()
@export_group("Weapon Stat Change Data")
@export var wpn_stat_change : WeaponStats = WeaponStats.new()
@export_group("Give Item Data")
@export var loot_table : LootTable = null
@export var target_item : ItemDefinition

@export_group("Event Option Requirements")
@export var gold_requirement = 0
@export var required_item : ItemDefinition = null
@export var required_item_type : Array[ItemConstants.ITEM_TYPE]  = []
@export var required_unit_stat : UnitStat = null
