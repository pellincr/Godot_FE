# ==============================================================================
# [Project Name]
# Copyright (c) 2026 Derc Development. 
# All rights reserved.
#
# File:     WeaponDefinition.gd
# Author:   Devin Murphy
# Created:  October 23, 2024
# Modified: December 26, 2025
# ==============================================================================

extends ItemDefinition
class_name WeaponDefinition
## Defines the properties and behavior of a weapon item.
##
## Extends [ItemDefinition] to add weapon-specific properties such as damage,
## hit chance, critical rates, weapon triangle types, and special effects.[br]
## [br]
## Weapons can have effectiveness against specific traits or weapon types,
## apply status ailments, and trigger special effects during combat.

# ==============================================================================
# Enums
# ==============================================================================

## Special effects that can be applied to weapons.
## @deprecated: No longer in use, use [SpecialEffect] instead
enum WEAPON_SPECIALS
{
	WEAPON_TRIANGLE_ADVANTAGE_EFFECTIVE,
	CRITICAL_DISABLED,
	VAMPYRIC, # make this modular and configurable
	NEGATES_FOE_DEFENSE,
	NEGATES_FOE_DEFENSE_ON_CRITICAL,
	HEAL_10_PERCENT_ON_TURN_BEGIN, # make this modular & extra configurable
	CANNOT_RETALIATE,
	HEAL_ON_COMBAT_END,
	DEVIL_REVERSAL
}
## Defines the action type, NONE is default ##CHANGE TO SKILL
enum ACTION_TYPES {
	NONE, #DEFAULT USED FOR WEAPONS WITHOUT ACTION
	HEAL,
	BLOCK,
	DEBUFF
	#TODO implement buff
}

## Defines the equipable locations of a weapon
enum EQUIP_SLOT {
	MAIN_HAND,
	OFF_HAND,
	VERSATILE,
	TWO_HANDED,
	NONE #should not be used
}

## Defines the equipable locations of a weapon
enum USE_TYPE {
	ATTACK,
	ACTION
}

# ==============================================================================
# Constants
# ==============================================================================

## Default hit chance for weapons.
const DEFAULT_HIT: int = 100

## Default weight for weapons.
const DEFAULT_WEIGHT: int = 5

## Default critical damage multiplier.
const DEFAULT_CRITICAL_MULTIPLIER: float = 3.0

## Default attacks per turn
const DEFAULT_ATTACKS_PER_TURN: int = 1

## Default target faction in this case others
const DEFAULT_TARGETS: ItemConstants.AVAILABLE_TARGETS = 0

## Default target faction in this case others
const DEFAULT_USE_TYPE: WeaponDefinition.USE_TYPE = WeaponDefinition.USE_TYPE.ATTACK

## Default scaling multiplier for weapons
const DEFAULT_SCALING_MULTIPLIER: float = 1.0

## Defualt experience multiplier for weapons
const DEFAULT_EXPERIENCE_MULTIPLIER: float = 1.0

# ==============================================================================
# Exported Variables - Weapon Type
# ==============================================================================
@export_group("Weapon Information")
## The category of weapon (sword, axe, lance, etc.).
@export var weapon_type : ItemConstants.WEAPON_TYPE

## The profile of the weapon.
@export var profile: ItemConstants.PROFILE

## Weight of the weapon, affects attack speed.
@export_range(0, 30, 1, "or_greater") var weight: int = DEFAULT_WEIGHT

## The support action this weapon can perform. TODO move this elsewhere
@export var action_type: ACTION_TYPES = ACTION_TYPES.NONE

## The type of damage this weapon deals (physical, magical, etc.).
@export var item_damage_type: Constants.DAMAGE_TYPE

## The stat used to calculate damage scaling.
@export var item_scaling_type: ItemConstants.SCALING_TYPE

## Multiplier applied to the scaling stat.
@export var item_scaling_multiplier: float = DEFAULT_SCALING_MULTIPLIER

## Valid target factions for this weapon.
@export var item_target_faction: Array[ItemConstants.AVAILABLE_TARGETS] = [DEFAULT_TARGETS]

# ==============================================================================
# Exported Variables - Weapon Requirements
# ==============================================================================

@export_group("Weapon Requirements")

## Class name that can exclusively use this weapon. Empty string means no restriction.
@export var class_lock: String = ""

@export var equip_slot : Array [EQUIP_SLOT] = []

# ==============================================================================
# Exported Variables - Combat Stats
# ==============================================================================

@export_group("Main Hand Stats")

## Base damage dealt by this weapon.
@export_range(0, 30, 1, "or_greater") var damage: int = 0

## Base hit chance percentage.
@export_range(0, 100, 1, "or_greater") var hit: int = DEFAULT_HIT

## Base critical hit chance percentage.
@export_range(0, 30, 1, "or_greater") var critical_chance: int = 0



## Damage multiplier applied on critical hits.
@export var critical_multiplier: float = DEFAULT_CRITICAL_MULTIPLIER

## Number of attacks this weapon performs per combat turn.
@export var attacks_per_combat_turn: int = DEFAULT_ATTACKS_PER_TURN

## Valid attack ranges for this weapon (1 = adjacent, 2 = one tile away, etc.).
@export_range(0, 30, 1) var attack_range: Array[int] = [1]

@export var use_type: int = DEFAULT_USE_TYPE

@export_subgroup("Main Hand Block")

## Block on 
@export var block_beginning_of_turn : int = 0
## Block on 
@export var block_end_of_turn : int = 0
## Block on 
@export var block_before_combat_exchange : int = 0
## Block on 
@export var block_after_combat_exchange : int = 0

@export_subgroup("Bonus Stats on Equip")

## Stat bonuses applied while this weapon is equipped.
@export var bonus_stat: UnitStat = UnitStat.new()

@export_subgroup("Weapon Effectiveness")

## Unit traits this weapon deals bonus damage against.
@export var weapon_effectiveness_trait: Array[unitConstants.TRAITS] = []

## Weapon types this weapon deals bonus damage against.
@export var weapon_effectiveness_weapon_type: Array[ItemConstants.WEAPON_TYPE] = []

@export_subgroup("Misc. Specials")

## Status ailment inflicted on hit (used by staves and special weapons). #TODO IMPLEMENT THIS
@export var status_ailment: EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.NONE

## Custom special effect resources activated while equipped.
@export var equipped_specials: Array[SpecialEffect] = []

@export_group("Off Hand Stats")

## Base damage dealt by this weapon.
@export_range(0, 30, 1, "or_greater") var offhand_damage: int = 0

## Base hit chance percentage.
@export_range(0, 100, 1, "or_greater") var offhand_hit: int = 0

## Base critical hit chance percentage.
@export_range(0, 30, 1, "or_greater") var offhand_critical_chance: int = 0

## Damage multiplier applied on critical hits.
@export var offhand_critical_multiplier: float = 0

## Number of attacks this weapon performs per combat turn.
@export var offhand_attacks_per_combat_turn: int = 0

@export_subgroup("Block")

## Block on 
@export var offhand_block_beginning_of_turn : int = 0
## Block on 
@export var offhand_block_end_of_turn : int = 0
## Block on 
@export var offhand_block_before_combat_exchange : int = 0
## Block on 
@export var offhand_block_after_combat_exchange : int = 0

@export_subgroup("Bonus Stats on Equip")

## Stat bonuses applied while this weapon is equipped.
@export var offhand_bonus_stat: UnitStat = UnitStat.new()

@export_subgroup("Weapon Effectiveness")

## Unit traits this weapon deals bonus damage against.
@export var offhand_weapon_effectiveness_trait: Array[unitConstants.TRAITS] = []

## Weapon types this weapon deals bonus damage against.
@export var offhand_weapon_effectiveness_weapon_type: Array[ItemConstants.WEAPON_TYPE] = []

@export_subgroup("Misc. Specials")

## Status ailment inflicted on hit (used by staves and special weapons). #TODO IMPLEMENT THIS
@export var offhand_status_ailment: EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.NONE

## Custom special effect resources activated while equipped.
@export var offhand_equipped_specials: Array[SpecialEffect] = []
