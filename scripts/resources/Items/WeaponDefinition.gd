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
## Defines the support action type, NONE is default
enum SUPPORT_TYPES {
	NONE,
	HEAL 
	#TODO implement buff
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

## Default scaling multiplier for weapons
const DEFAULT_SCALING_MULTIPLIER: float = 1.0

## Defualt experience multiplier for weapons
const DEFAULT_EXPERIENCE_MULTIPLIER: float = 1.0

# ==============================================================================
# Exported Variables - Weapon Type
# ==============================================================================
@export_group("Weapon Type")
## The category of weapon (sword, axe, lance, etc.).
@export var weapon_type : ItemConstants.WEAPON_TYPE

## The alignment of the weapon.
## @deprecated: No longer used in combat calculations.
@export var alignment: ItemConstants.ALIGNMENT

## The physical weapon triangle type for mundane weapons.
@export var physical_weapon_triangle_type: ItemConstants.MUNDANE_WEAPON_TRIANGLE

## The magical weapon triangle type for magic weapons.
@export var magic_weapon_triangle_type: ItemConstants.MAGICAL_WEAPON_TRIANGLE

## The support action this weapon can perform.
@export var support_type: SUPPORT_TYPES = SUPPORT_TYPES.NONE

## The type of damage this weapon deals (physical, magical, etc.).
@export var damage_type: Constants.DAMAGE_TYPE

## The stat used to calculate damage scaling.
@export var scaling_type: ItemConstants.SCALING_TYPE

## Multiplier applied to the scaling stat.
@export var scaling_multiplier: float = DEFAULT_SCALING_MULTIPLIER

## Valid target factions for this weapon.
@export var target_factions: Array[ItemConstants.AVAILABLE_TARGETS] = [DEFAULT_TARGETS]

# ==============================================================================
# Exported Variables - Weapon Requirements
# ==============================================================================

@export_group("Weapon Requirements")

## Minimum weapon mastery rank required to wield this weapon. #TODO IMPLEMENT THESE CHANGES
@export var required_mastery: ItemConstants.MASTERY_REQUIREMENT = ItemConstants.MASTERY_REQUIREMENT.E

## Class name that can exclusively use this weapon. Empty string means no restriction.
@export var class_lock: String = ""


# ==============================================================================
# Exported Variables - Combat Stats
# ==============================================================================

@export_group("Combat Stats")

## Base damage dealt by this weapon.
@export_range(0, 30, 1, "or_greater") var damage: int = 0

## Base hit chance percentage.
@export_range(0, 100, 1, "or_greater") var hit: int = DEFAULT_HIT

## Base critical hit chance percentage.
@export_range(0, 30, 1, "or_greater") var critical_chance: int = 0

## Weight of the weapon, affects attack speed.
@export_range(0, 30, 1, "or_greater") var weight: int = DEFAULT_WEIGHT

## Damage multiplier applied on critical hits.
@export var critical_multiplier: float = DEFAULT_CRITICAL_MULTIPLIER

## Number of attacks this weapon performs per combat turn.
@export var attacks_per_combat_turn: int = DEFAULT_ATTACKS_PER_TURN

## Valid attack ranges for this weapon (1 = adjacent, 2 = one tile away, etc.).
@export_range(0, 30, 1) var attack_range: Array[int] = [1]


# ==============================================================================
# Exported Variables - Weapon Specials
# ==============================================================================

@export_group("Weapon Specials")

@export_subgroup("Bonus Stats on Equip")

## Stat bonuses applied while this weapon is equipped.
@export var bonus_stat: UnitStat = UnitStat.new()

@export_subgroup("Weapon Effectiveness")

## Unit traits this weapon deals bonus damage against.
@export var effectiveness_traits: Array[unitConstants.TRAITS] = []

## Weapon types this weapon deals bonus damage against.
@export var effectiveness_weapon_types: Array[ItemConstants.WEAPON_TYPE] = []

@export_subgroup("Misc. Specials")

## Status ailment inflicted on hit (used by staves and special weapons).
@export var status_ailment: EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.NONE

## Built-in special effects for this weapon.
## @deprecated: No longer in use, use special efects instead.
@export var specials: Array[WEAPON_SPECIALS] = []

## Custom special effect resources activated while equipped.
@export var equipped_specials: Array[SpecialEffect] = []

## Experience multiplier for combat with this weapon.
## Values greater than 1.0 grant bonus experience.
@export var experience_modifier: float = DEFAULT_EXPERIENCE_MULTIPLIER #TODO IMPLEMENT THIS MODIFIER
