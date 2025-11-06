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

#Keyboard Icons
const KEYBOARD_NAVIGATION_ICON := preload("res://resources/sprites/controls/keyboard/_.png")
const KEYBOARD_LEFT_ICON := preload("res://resources/sprites/controls/keyboard/a.png")
const KEYBOARD_RIGHT_ICON := preload("res://resources/sprites/controls/keyboard/d.png")
const KEYBOARD_UP_ICON := preload("res://resources/sprites/controls/keyboard/w.png")
const KEYBOARD_DOWN_ICON := preload("res://resources/sprites/controls/keyboard/s.png")
const KEYBOARD_LB_ICON := preload("res://resources/sprites/controls/keyboard/q.png")
const KEYBOARD_RB_ICON := preload("res://resources/sprites/controls/keyboard/e.png")
const KEYBOARD_CONFIRM_ICON := preload("res://resources/sprites/controls/keyboard/enteralt.png")
const KEYBOARD_BACK_ICON := preload("res://resources/sprites/controls/keyboard/backspace.png")
const KEYBOARD_DETAILS_ICON := preload("res://resources/sprites/controls/keyboard/controltext.png")
const KEYBOARD_PAUSE_ICON := preload("res://resources/sprites/controls/keyboard/escape.png")

#PS Icons
const PS_NAVIGATION_ICON := preload("res://resources/sprites/controls/ps_controller/_.png")
const PS_LEFT_ICON := preload("res://resources/sprites/controls/ps_controller/a.png")
const PS_RIGHT_ICON := preload("res://resources/sprites/controls/ps_controller/d.png")
const PS_UP_ICON := preload("res://resources/sprites/controls/ps_controller/w.png")
const PS_DOWN_ICON := preload("res://resources/sprites/controls/ps_controller/s.png")
const PS_LB_ICON := preload("res://resources/sprites/controls/ps_controller/l1.png")
const PS_RB_ICON := preload("res://resources/sprites/controls/ps_controller/r1.png")
const PS_CONFIRM_ICON := preload("res://resources/sprites/controls/ps_controller/X Button.png")
const PS_BACK_ICON := preload("res://resources/sprites/controls/ps_controller/circle.png")
const PS_DETAILS_ICON := preload("res://resources/sprites/controls/ps_controller/square.png")
const PS_PAUSE_ICON := preload("res://resources/sprites/controls/ps_controller/start.png")

const test = preload("res://resources/sprites/icons/campaign_map_icons/major_combat_campaign_map_icon.png")
#XBOX Icons
const XBOX_NAVIGATION_ICON := preload("res://resources/sprites/controls/xbox_controller/_.png")
const XBOX_LEFT_ICON := preload("res://resources/sprites/controls/xbox_controller/a.png")
const XBOX_RIGHT_ICON := preload("res://resources/sprites/controls/xbox_controller/d.png")
const XBOX_UP_ICON := preload("res://resources/sprites/controls/xbox_controller/w.png")
const XBOX_DOWN_ICON := preload("res://resources/sprites/controls/xbox_controller/s.png")
const XBOX_LB_ICON := preload("res://resources/sprites/controls/xbox_controller/lb 1.png")
const XBOX_RB_ICON := preload("res://resources/sprites/controls/xbox_controller/rb 1.png")
const XBOX_CONFIRM_ICON := preload("res://resources/sprites/controls/xbox_controller/a_button.png")
const XBOX_BACK_ICON := preload("res://resources/sprites/controls/xbox_controller/b.png")
const XBOX_DETAILS_ICON := preload("res://resources/sprites/controls/xbox_controller/x.png")
const XBOX_PAUSE_ICON := preload("res://resources/sprites/controls/xbox_controller/start.png")

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
	KEYBOARD, PS, XBOX, SWITCH, GENERAL
}

var current_control_state : CONTROL_STATE
var current_controller_state : CONTROLLER_STATE

func _ready() -> void:
	InputHelper.device_changed.connect(_on_device_changed)
	_on_device_changed(InputHelper.device,InputHelper.device_index)
#	set_control_state(CONTROL_STATE.BATTLE_PREP_TRAINING_GROUNDS_GIVE_EXP)
#	set_controller_state(CONTROLLER_STATE.PS)

func _on_device_changed(device: String, _device_index: int):
	match device:
		"keyboard":
			set_controller_state(CONTROLLER_STATE.KEYBOARD)
		"playstation":
			set_controller_state(CONTROLLER_STATE.PS)
		"xbox":
			set_controller_state(CONTROLLER_STATE.XBOX)
		"switch":
			set_controller_state(CONTROLLER_STATE.SWITCH)
		"steamdeck":
			pass
		"generic":
			pass


func set_container_visibility(container,visibility):
	container.visible = visibility

func set_label_text(label,text):
	label.text = text


func set_icon_texture(icon,texture):
	icon.texture = texture

func set_control_state(state:CONTROL_STATE):
	current_control_state = state
	update_by_control_state()

func set_controller_state(state:CONTROLLER_STATE):
	current_controller_state = state
	update_by_controller_state()

func update_by_controller_state():
	match current_controller_state:
		CONTROLLER_STATE.KEYBOARD:
			set_icon_texture(navigation_icon,KEYBOARD_NAVIGATION_ICON)
			set_icon_texture(left_icon,KEYBOARD_LEFT_ICON)
			set_icon_texture(down_icon,KEYBOARD_DOWN_ICON)
			set_icon_texture(up_icon,KEYBOARD_UP_ICON)
			set_icon_texture(right_icon,KEYBOARD_RIGHT_ICON)
			set_icon_texture(left_bumper_icon,KEYBOARD_LB_ICON)
			set_icon_texture(right_bumper_icon, KEYBOARD_RB_ICON)
			set_icon_texture(confirm_icon,KEYBOARD_CONFIRM_ICON)
			set_icon_texture(back_icon,KEYBOARD_BACK_ICON)
			set_icon_texture(details_icon,KEYBOARD_DETAILS_ICON)
			set_icon_texture(pause_game_icon,KEYBOARD_PAUSE_ICON)
		CONTROLLER_STATE.PS:
			set_icon_texture(navigation_icon,PS_NAVIGATION_ICON)
			set_icon_texture(left_icon,PS_LEFT_ICON)
			set_icon_texture(down_icon,PS_DOWN_ICON)
			set_icon_texture(up_icon,PS_UP_ICON)
			set_icon_texture(right_icon,PS_RIGHT_ICON)
			set_icon_texture(left_bumper_icon,PS_LB_ICON)
			set_icon_texture(right_bumper_icon, PS_RB_ICON)
			set_icon_texture(confirm_icon,PS_CONFIRM_ICON)
			set_icon_texture(back_icon,PS_BACK_ICON)
			set_icon_texture(details_icon,PS_DETAILS_ICON)
			set_icon_texture(pause_game_icon,PS_PAUSE_ICON)
		CONTROLLER_STATE.XBOX:
			set_icon_texture(navigation_icon,XBOX_NAVIGATION_ICON)
			set_icon_texture(left_icon,XBOX_LEFT_ICON)
			set_icon_texture(down_icon,XBOX_DOWN_ICON)
			set_icon_texture(up_icon,XBOX_UP_ICON)
			set_icon_texture(right_icon,XBOX_RIGHT_ICON)
			set_icon_texture(left_bumper_icon,XBOX_LB_ICON)
			set_icon_texture(right_bumper_icon, XBOX_RB_ICON)
			set_icon_texture(confirm_icon,XBOX_CONFIRM_ICON)
			set_icon_texture(back_icon,XBOX_BACK_ICON)
			set_icon_texture(details_icon,XBOX_DETAILS_ICON)
			set_icon_texture(pause_game_icon,XBOX_PAUSE_ICON)
		CONTROLLER_STATE.SWITCH:
			set_icon_texture(navigation_icon,XBOX_NAVIGATION_ICON)
			set_icon_texture(left_icon,XBOX_LEFT_ICON)
			set_icon_texture(down_icon,XBOX_DOWN_ICON)
			set_icon_texture(up_icon,XBOX_UP_ICON)
			set_icon_texture(right_icon,XBOX_RIGHT_ICON)
			set_icon_texture(left_bumper_icon,XBOX_LB_ICON)
			set_icon_texture(right_bumper_icon, XBOX_RB_ICON)
			set_icon_texture(confirm_icon,XBOX_CONFIRM_ICON)
			set_icon_texture(back_icon,XBOX_BACK_ICON)
			set_icon_texture(details_icon,XBOX_DETAILS_ICON)
			set_icon_texture(pause_game_icon,XBOX_PAUSE_ICON)


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
			set_container_visibility(right_bumper_container, true)
			set_label_text(right_bumper_label, "Screen Right")
			set_container_visibility(right_bumper_container, true)
			set_label_text(left_bumper_label, "Screen Left")
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
