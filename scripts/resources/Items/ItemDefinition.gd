# ==============================================================================
# [Project Name]
# Copyright (c) 2026 Derc Development. 
# All rights reserved.
#
# File:     ItemDefinition.gd
# Author:   Devin Murphy
# Created:  October 7, 2024
# Modified: December 26, 2025
# ==============================================================================

extends Resource
class_name ItemDefinition
## Defines the properties and behaviors of an in-game item.
##
## ItemDefinition is a [Resource] that serves as a data container for all item
## metadata including durability, pricing, visual representation, and stat bonuses.
## Items can be equippable, have limited uses, and can provide passive bonuses when
## held in a unit's inventory.[br]
## [br]
## Items support multiple states including normal, expended (out of uses but not
## destroyed), and broken. Durability can refresh after combat based on the
## configured [member refreshes_after_combat] type.[br]
## [br]
## [b]Usage:[/b]
## [codeblock]
## var sword := ItemDefinition.new()
## sword.name = "Iron Sword"
## sword.uses = 30
## sword.max_uses = 30
## sword.worth = 500
##
## # Use the item
## sword.expend_use()
##
## # Get current sell price (scales with durability)
## var sell_price := sword.calculate_price()
## [/codeblock]
##
## @todo: TOD-001 - Clarify relationship between price and worth properties.
## @todo: TOD-002 - Consider adding null safety for icon property in get_icon().

# ==============================================================================
# ENUMS
# ==============================================================================

## Defines how an item's uses are restored after combat encounters.
enum REFRESH_TYPE {
	## Item does not refresh uses after combat.
	NO_REFRESH,
	## Item restores a flat amount of uses equal to [member refresh_weight].
	FLAT,
	## Item restores a percentage of current uses based on [member refresh_weight].
	PERCENTAGE,
	## Item fully restores all uses to [member max_uses].
	ALL,
}

# ==============================================================================
# EXPORTED VARIABLES - Item Info
# ==============================================================================

@export_group("Item Info")

## The display name of the item shown to players.
@export var name: String = ""

## Unique database key used for item lookups and serialization.
@export var db_key: String = ""

## Whether this item can be equipped by a unit.
@export var equippable: bool = false

## Detailed description of the item displayed in tooltips and menus.
@export var description: String = ""

## The category or classification of this item.
@export var item_type: ItemConstants.ITEM_TYPE = ItemConstants.ITEM_TYPE.WEAPON

## The rarity tier of this item, affecting drop rates and value, uses [Rarity].
@export var rarity: Rarity

# ==============================================================================
# EXPORTED VARIABLES - Durability
# ==============================================================================

@export_subgroup("Durability")

## Current remaining uses of the item. Set to -1 for items without use limits.
## When uses reaches 0, the item either enters expended state or breaks.
@export_range(-1, 100, 1, "or_greater") var uses: int = 1

## Maximum number of uses this item can hold.
@export_range(1, 2, 1, "or_greater") var max_uses: int = 1

## If [code]true[/code], the item never loses uses when expend_use() is called.
@export var unbreakable: bool = false

## If [code]true[/code], the item enters an expended state at 0 uses instead of
## being destroyed. Expended items may display differently and be restorable.
@export var has_expended_state: bool = false

## Determines if and how this item's uses are restored after combat.
## See [enum REFRESH_TYPE] for available options.
@export var refreshes_after_combat: REFRESH_TYPE = REFRESH_TYPE.NO_REFRESH

## The amount or percentage used for use restoration after combat.
## Interpretation depends on [member refreshes_after_combat]:
## [br]- [constant REFRESH_TYPE.FLAT]: Number of uses to restore.
## [br]- [constant REFRESH_TYPE.PERCENTAGE]: Percentage of current uses to add.
## [br]- Other types: Ignored.
@export var refresh_weight: int = 0

# ==============================================================================
# EXPORTED VARIABLES - Price
# ==============================================================================

@export_subgroup("Price")

## Base value of the item at full durability.
## Used to calculate [member price] based on remaining uses.
@export_range(0, 10000, 1, "or_greater") var worth: int = 100

## If [code]true[/code], this item cannot be sold to merchants.
@export var unsellable: bool = false

## Current calculated price based on durability.
## Updated automatically when [method expend_use] is called.
## @todo: TOD-001 - Consider making this computed-only or clarifying update timing.
@export var price: int = 0

# ==============================================================================
# EXPORTED VARIABLES - Item Specials
# ==============================================================================

@export_group("Item Specials")
@export_subgroup("Gives Unit Bonus Stats When Held in Inventory")

## Combat stat bonuses applied to a unit while this item is in their inventory.
## These bonuses are passive and do not require the item to be equipped.
@export var inventory_bonus_stats: CombatUnitStat = null

## Growth rate bonuses applied to a unit while this item is in their inventory.
## Affects stat gains on level up.
@export var inventory_growth_bonus_stats: UnitStat = null

## Array of special effects that trigger while this item is held.
@export var held_specials: Array[SpecialEffect] = []

# ==============================================================================
# EXPORTED VARIABLES - Unlockables
# ==============================================================================

@export_group("unlockables")

## Whether this item has been unlocked and is available for use.
## Locked items may be hidden from shops or loot tables.
@export var unlocked: bool = true

# ==============================================================================
# EXPORTED VARIABLES - Visuals
# ==============================================================================

@export_group("Visuals")

## Icon texture displayed for this item in inventory and menus.
@export var icon: Texture2D

## Alternative icon displayed when the item is in expended state.
## Only used if [member has_expended_state] is [code]true[/code].
@export var expended_icon: Texture2D

# ==============================================================================
# PUBLIC VARIABLES
# ==============================================================================

## Tracks if the item has been affected by an event or other metadata-altering
## interaction. Used to mark items that have been modified from their base state.
var augmented: bool = false

## Whether this item is currently in an expended state (0 uses but not destroyed).
## Only relevant when [member has_expended_state] is [code]true[/code].
var expended: bool = false

# ==============================================================================
# PUBLIC METHODS
# ==============================================================================

## Consumes one use of the item.
##
## If the item is [member unbreakable], no use is consumed. When uses reach 0,
## the item either enters [member expended] state (if [member has_expended_state]
## is [code]true[/code]) or is considered broken. The [member price] is
## recalculated after each use.[br]
## [br]
## [codeblock]
## var potion := preload("res://items/health_potion.tres")
## potion.expend_use()  # Uses: 3 -> 2
## [/codeblock]
func expend_use() -> void:
	#check if the weapon is unbreakable, this means it doesnt expend any uses
	if unbreakable:
		return
	# remove the use
	uses = uses - 1
	
	if uses <= 0:
		if has_expended_state:
			# set the item to "expended"
			expended = true
		else : 
			push_warning("ItemDefinition: %s has broken (uses depleted)" % name)
	
	price = calculate_price()

## Calculates the current price based on remaining durability.
##
## For [member unbreakable] items, returns full [member worth]. For other items,
## price scales linearly with the ratio of current [member uses] to
## [member max_uses].[br]
## [br]
## Returns: The calculated price as an integer.
##
## [codeblock]
## # Item with worth=100, uses=5, max_uses=10
## var price := item.calculate_price()  # Returns 50
## [/codeblock]
func calculate_price():
	if unbreakable:
		return worth
	else: 
		var _use_ratio = (float(uses) / float(max_uses))
		var _price =  int(float(worth) * _use_ratio)
		return _price

## Restores uses after combat based on [member refreshes_after_combat] type.
##
## The restoration behavior depends on the configured refresh type:
## [br]- [constant REFRESH_TYPE.NO_REFRESH]: No effect.
## [br]- [constant REFRESH_TYPE.FLAT]: Adds [member refresh_weight] uses.
## [br]- [constant REFRESH_TYPE.PERCENTAGE]: Adds a percentage of current uses.
## [br]- [constant REFRESH_TYPE.ALL]: Restores to [member max_uses].
##
## [codeblock]
## # After combat, refresh all items in inventory
## for item in inventory:
##     item.refresh_uses()
## [/codeblock]
func refresh_uses() -> void:
	match refreshes_after_combat: 
		REFRESH_TYPE.NO_REFRESH:
			pass
		REFRESH_TYPE.FLAT:
			uses = clampi(uses + refresh_weight, 1, max_uses)
		REFRESH_TYPE.PERCENTAGE:
			uses = clampi(uses + int(float(uses) * float(refresh_weight)/100.0), 1, max_uses)
		REFRESH_TYPE.ALL:
			uses = max_uses

## Returns the appropriate icon texture based on item state.
##
## If the item [member has_expended_state], is currently [member expended], and
## has a valid [member expended_icon], returns the expended icon. Otherwise
## returns the standard [member icon].[br]
## [br]
## Returns: The [Texture2D] to display for this item.
##
## [codeblock]
## texture_rect.texture = item.get_icon()
## [/codeblock]
func get_icon() -> Texture2D:
	if has_expended_state and expended:
		if expended_icon != null:
			return expended_icon
	return icon
