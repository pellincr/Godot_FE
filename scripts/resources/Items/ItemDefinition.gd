extends Resource
class_name ItemDefinition

enum REFRESH_TYPE {
	NO_REFRESH,
	FLAT,
	PERCENTAGE,
	ALL
}

@export_group("Item Info")
@export var name = ""
@export var db_key = ""
@export var equippable = false
@export var description : String
@export var item_type : ItemConstants.ITEM_TYPE = 0
var augmented: bool = false # tracks if the item has been effected by an event or other metadata atlering interaction

@export var rarity : Rarity

@export_subgroup("Durability")
@export_range(-1, 100, 1, "or_greater") var uses = 1
@export_range(1, 2, 1, "or_greater") var max_uses = 1
@export var unbreakable = false
@export var has_expended_state = false
var expended = false
@export var refreshes_after_combat : REFRESH_TYPE = REFRESH_TYPE.NO_REFRESH
@export var refresh_weight : int  = 0

@export_subgroup("Price")
@export_range(0,1000,1, "or_greater") var worth = 100
@export var unsellable : bool = false
var price : int = calculate_price()

@export_group("Item Specials")
@export_subgroup("Gives Unit Bonus Stats When Held in Inventory")
@export var inventory_bonus_stats : CombatUnitStat = null
@export var inventory_growth_bonus_stats : UnitStat = null

@export_group("Visuals")
@export var icon: Texture2D
@export var expended_icon : Texture2D

func expend_use():
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
			print(name + " broke!")

func calculate_price():
	if unbreakable:
		return worth
	else: 
		return floor(worth * (uses / max_uses))

func refresh_uses():
	# what kind of refresh is it?
	match refreshes_after_combat: 
		REFRESH_TYPE.NO_REFRESH:
			pass
		REFRESH_TYPE.FLAT:
			uses = clampi(uses + refresh_weight, max_uses, 1)
		REFRESH_TYPE.PERCENTAGE:
			uses = clampi(uses + int(uses * refresh_weight/100), max_uses, 1)
		REFRESH_TYPE.ALL:
			uses = max_uses

# Created so that multi-state items can return correct visuals
func get_icon() -> Texture2D:
	if has_expended_state and expended:
		if expended_icon != null:
			return expended_icon
	return icon
