extends HBoxContainer

class_name ControlsUI

@onready var navigation_container: HBoxContainer = $NavigationContainer
@onready var navigation_label: Label = $NavigationContainer/NavigationLabel
@onready var navigation_icon: TextureRect = $NavigationContainer/NavigationIcon

@onready var left_container: HBoxContainer = $LeftContainer
@onready var left_label: Label = $LeftContainer/LeftLabel
@onready var left_icon: TextureRect = $LeftContainer/LeftIcon

@onready var down_container: HBoxContainer = $DownContainer
@onready var down_label: Label = $DownContainer/DownLabel
@onready var down_icon: TextureRect = $DownContainer/DownIcon

@onready var up_container: HBoxContainer = $UpContainer
@onready var up_label: Label = $UpContainer/UpLabel
@onready var up_icon: TextureRect = $UpContainer/UpIcon

@onready var right_container: HBoxContainer = $RightContainer
@onready var right_label: Label = $RightContainer/RightLabel
@onready var right_icon: TextureRect = $RightContainer/RightIcon

@onready var left_bumper_container: HBoxContainer = $LeftBumperContainer
@onready var left_bumper_label: Label = $LeftBumperContainer/LeftBumperLabel
@onready var left_bumper_icon: TextureRect = $LeftBumperContainer/LeftBumperIcon

@onready var right_bumper_container: HBoxContainer = $RightBumperContainer
@onready var right_bumper_label: Label = $RightBumperContainer/RightBumperLabel
@onready var right_bumper_icon: TextureRect = $RightBumperContainer/RightBumperIcon

@onready var confirm_container: HBoxContainer = $ConfirmContainer
@onready var confirm_label: Label = $ConfirmContainer/ConfirmLabel
@onready var confirm_icon: TextureRect = $ConfirmContainer/ConfirmIcon

@onready var back_container: HBoxContainer = $BackContainer
@onready var back_label: Label = $BackContainer/BackLabel
@onready var back_icon: TextureRect = $BackContainer/BackIcon

@onready var details_container: HBoxContainer = $DetailsContainer
@onready var details_label: Label = $DetailsContainer/DetailsLabel
@onready var details_icon: TextureRect = $DetailsContainer/DetailsIcon

@onready var pause_game_container: HBoxContainer = $PauseGameContainer
@onready var pause_game_lable: Label = $PauseGameContainer/PauseGameLable
@onready var pause_game_icon: TextureRect = $PauseGameContainer/PauseGameIcon


#The State that determines the controls currently being displayed
enum CONTROL_STATE{
	DRAFT, 
	CAMPAIGN_MAP,
	BATTLE_PREP_MENU, 
	BATTLE_PREP_UNIT_SELECT, 
	BATTLE_PREP_SWAP_SPACES,
	BATTLE_PREP_SHOP_WHERE, BATTLE_PREP_SHOP_WHAT, 
	BATTLE_PREP_INVENTORY_UNIT_SELECT, BATTLE_PREP_INVENTORY_MANAGE_ITEMS, BATTLE_PREP_INVENTORY_TRADE,
	BATTLE_PREP_TRAINING_GROUNDS_UNIT_SELECT, BATTLE_PREP_TRAINING_GROUNDS_GIVE_EXP,
	BATTLE_PREP_GRAVEYARD_UNIT_SELECT, BATTLE_PREP_GRAVEYARD_TOMBSTONE
}

#The State the derermines i
enum CONTROLLER_STATE{
	KEYBOARD, CONTROLLER
}

var current_control_state : CONTROL_STATE
var current_controller_state : CONTROLLER_STATE

#func _ready() -> void:
#	set_control_state(CONTROL_STATE.BATTLE_PREP_TRAINING_GROUNDS_GIVE_EXP)

func set_container_visibility(container,visibility):
	container.visible = visibility

func set_label_text(label,text):
	label.text = text


func set_icon_textur(icon,texture):
	icon.texure = texture


func set_control_state(state:CONTROL_STATE):
	current_control_state = state
	update_by_control_state()

func general_control_visibility():
	set_container_visibility(navigation_container,true)
	set_container_visibility(confirm_container,true)
	set_container_visibility(pause_game_container,true)

func battle_prep_sub_menu_general_visibility():
	general_control_visibility()
	set_container_visibility(back_container,true)

func update_by_control_state():
	hide_all_controls()
	match current_control_state:
		CONTROL_STATE.DRAFT:
			general_control_visibility()
			set_container_visibility(left_bumper_container,true)
			set_label_text(left_bumper_label,"Prev View")
			set_container_visibility(right_bumper_container,true)
			set_label_text(right_bumper_label,"Next View")
			set_label_text(confirm_label,"Draft")
		CONTROL_STATE.CAMPAIGN_MAP:
			general_control_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_MENU:
			general_control_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_UNIT_SELECT:
			battle_prep_sub_menu_general_visibility()
		CONTROL_STATE.BATTLE_PREP_SWAP_SPACES:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Swap")
		CONTROL_STATE.BATTLE_PREP_SHOP_WHERE:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_SHOP_WHAT:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Buy/Sell")
		CONTROL_STATE.BATTLE_PREP_INVENTORY_UNIT_SELECT:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_INVENTORY_MANAGE_ITEMS:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Store/Take")
		CONTROL_STATE.BATTLE_PREP_INVENTORY_TRADE:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label, "Trade")
		CONTROL_STATE.BATTLE_PREP_TRAINING_GROUNDS_UNIT_SELECT:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_TRAINING_GROUNDS_GIVE_EXP:
			set_container_visibility(left_container,true)
			set_label_text(left_label,"-10XP")
			set_container_visibility(down_container,true)
			set_label_text(down_label,"-1XP")
			set_container_visibility(up_container,true)
			set_label_text(up_label,"+1XP")
			set_container_visibility(right_container,true)
			set_label_text(right_label,"+10XP")
			set_container_visibility(left_bumper_container,true)
			set_label_text(left_bumper_label,"Clear")
			set_container_visibility(right_bumper_container,true)
			set_label_text(right_bumper_label,"Next Lvl")
			set_container_visibility(confirm_container,true)
			set_label_text(confirm_label,"Train")
			set_container_visibility(back_container,true)
		CONTROL_STATE.BATTLE_PREP_GRAVEYARD_UNIT_SELECT:
			battle_prep_sub_menu_general_visibility()
			set_label_text(confirm_label,"Confirm")
		CONTROL_STATE.BATTLE_PREP_GRAVEYARD_TOMBSTONE:
			set_container_visibility(confirm_container,true)
			set_label_text(confirm_label,"Revive")

func hide_all_controls():
	set_container_visibility(navigation_container,false)
	set_container_visibility(left_container,false)
	set_container_visibility(down_container,false)
	set_container_visibility(up_container,false)
	set_container_visibility(right_container,false)
	set_container_visibility(left_bumper_container,false)
	set_container_visibility(right_bumper_container,false)
	set_container_visibility(confirm_container,false)
	set_container_visibility(back_container,false)
	set_container_visibility(details_container,false)
	set_container_visibility(pause_game_container,false)
