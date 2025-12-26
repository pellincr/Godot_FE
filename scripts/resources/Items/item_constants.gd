# ==============================================================================
# [Project Name]
# Copyright (c) 2026 Derc Development. 
# All rights reserved.
#
# File:     ItemDefinition.gd
# Author:   Devin Murphy
# Created:  July 23, 2025
# Modified: December 26, 2025
# ==============================================================================
extends Node
#class_name ItemConstants - Loaded Globally

## Global constants and enumerations for the item system.
##
## This autoload provides all item-related enumerations used throughout the
## game's inventory, combat, and equipment systems. Reference enum values
## using [code]ItemConstants.ENUM_NAME.VALUE[/code].[br]
## [br]
## [b]Example:[/b]
## [codeblock]
## var weapon_type: ItemConstants.WEAPON_TYPE = ItemConstants.WEAPON_TYPE.SWORD
## var damage_type: ItemConstants.DAMAGE_TYPE = ItemConstants.DAMAGE_TYPE.PHYSICAL
## [/codeblock]
##
## @todo: TOD-001 - Evaluate and remove MASTERY_REQUIREMENT enum if permanently unused.
## @todo: TOD-002 - Evaluate and remove ALIGNMENT enum if permanently deprovisioned.
## @todo: TOD-003 - Expand SCALING_TYPE to include additional unit stats.

# ==============================================================================
# Item Classification
# ==============================================================================

## Defines the primary category of an item.
enum ITEM_TYPE {
	## Weapons used for physical or magical attacks.
	WEAPON = 0,
	## Staves used for healing, buffs, or utility magic.
	STAFF = 1,
	## Consumable items that can be used during battle or on the map.
	USEABLE_ITEM = 2,
	## accessories and armor pieces, effect a units stats when held in inventory
	EQUIPMENT = 3,
	## Valuable items primarily for selling or quest purposes.
	TREASURE = 4,
}

# ==============================================================================
# Weapon System
# ==============================================================================

## Defines the specific type of weapon, determining, sounds, equiability, 
## and weapon triangle relationships.
enum WEAPON_TYPE {
	## No weapon type assigned.
	NONE = 0,
	## Swords. Advantage against axes in mundane triangle.
	SWORD = 1,
	## Axes. Advantage against lances in mundane triangle.
	AXE = 2,
	## Polearm weapons. Advantage against swords in mundane triangle.
	LANCE = 3,
	## Ranged physical weapons.
	BOW = 4,
	## Unarmed combat weapons such as gauntlets, do not participate in weapon triangle.
	FIST = 5,
	## Magical staves for casting spells.
	STAFF = 6,
	## Dark magic tomes. Advantage against nature in magical triangle.
	DARK = 7,
	## Light magic tomes. Advantage against dark in magical triangle.
	LIGHT = 8,
	## Nature magic tomes. Advantage against light in magical triangle.
	NATURE = 9,
	## Weapons used by animal units.
	ANIMAL = 10,
	## Weapons used by monster units.
	MONSTER = 11,
	## Defensive shields, typically favoring defense over attack.
	SHIELD = 12,
	## Rnaged bladed weapons that have incereased cirtical damage.
	DAGGER = 13,
	## Support items that provide buffs to nearby allies.
	BANNER = 14,
}

# ==============================================================================
# Combat System
# ==============================================================================

## Defines how damage is calculated and what defenses apply.
enum DAMAGE_TYPE {
	## Physical damage, reduced by Defense stat.
	PHYSICAL = 0,
	## Magical damage, reduced by Resistance stat.
	MAGIC = 1,
	## True damage that ignores all defensive stats.
	PURE = 2,
}

## Weapon triangle for mundane (physical) weapons.
## Sword beats Axe, Axe beats Lance, Lance beats Sword.
enum MUNDANE_WEAPON_TRIANGLE {
	## Weapon is not part of the mundane triangle.
	NONE = 0,
	## Sword type. Advantage against [constant AXE].
	SWORD = 1,
	## Axe type. Advantage against [constant LANCE].
	AXE = 2,
	## Lance type. Advantage against [constant SWORD].
	LANCE = 3,
}

## Weapon triangle for magical weapons.
## Nature beats Dark, Dark beats Light, Light beats Nature.
enum MAGICAL_WEAPON_TRIANGLE {
	## Weapon is not part of the magical triangle.
	NONE = 0,
	## Nature magic. Advantage against [constant LIGHT].
	NATURE = 1,
	## Light magic. Advantage against [constant DARK].
	LIGHT = 2,
	## Dark magic. Advantage against [constant NATURE].
	DARK = 3,
}

## Determines which stat affects the weapon's damage output.
##
## @todo: TOD-003 - Expand to include additional unit stats (Speed, Luck, etc.).
enum SCALING_TYPE {
	## Damage scales with the Strength stat.
	STRENGTH = 0,
	## Damage scales with the Skill stat.
	SKILL = 1,
	## Damage scales with the Magic stat.
	MAGIC = 2,
	## Damage scales with the Constitution stat.
	CONSTITUTION = 3,
	## No stat scaling applied.
	NONE = 4,
}

# ==============================================================================
# Targeting System
# ==============================================================================

## Defines valid targets for items, weapons, and abilities.
enum AVAILABLE_TARGETS {
	## Can only target enemy units.
	ENEMY = 0,
	## Can only target allied units (excluding self).
	ALLY = 1,
	## Can only target the user.
	SELF = 2,
}

# ==============================================================================
# Consumable Items
# ==============================================================================

## Defines the effect type when a consumable item is used.
enum CONSUMABLE_USE_EFFECT {
	## No use effect.
	NONE = 0,
	## Restores HP to the target. ALl items with this tag are Available in shops.
	HEAL = 1,
	## Deals damage to the target.
	DAMAGE = 2,
	## Permanent boosts a stat. Common items available in shops.
	STAT_BOOST = 3,
	## Applies a status effect (buff or debuff).
	STATUS_EFFECT = 4,
	## Unlocks doors or chests.
	KEY = 5,
}

# ==============================================================================
# Deprecated / Unused Enums
# ==============================================================================

## Weapon mastery rank requirements.
##
## @deprecated: This enum is not currently in use. Evaluate for removal.
## @todo: TOD-001 - Remove if permanently unused.
enum MASTERY_REQUIREMENT {
	## Rank E - Lowest mastery level.
	E = 0,
	## Rank D.
	D = 1,
	## Rank C.
	C = 2,
	## Rank B.
	B = 3,
	## Rank A.
	A = 4,
	## Rank S - Highest mastery level.
	S = 5,
}


## Item alignment categories for combat exchanges.
##
## @deprecated: This system has been deprovisioned. Evaluate for removal.
## @todo: TOD-002 - Remove if permanently deprovisioned.
enum ALIGNMENT {
	## Mundane physical alignment.
	MUNDANE = 0,
	## Agility-focused alignment.
	NIMBLE = 1,
	## Magic-focused alignment.
	MAGIC = 2,
	## Defense-focused alignment.
	DEFENSIVE = 3,
	## No alignment assigned.
	NONE = 4,
}
