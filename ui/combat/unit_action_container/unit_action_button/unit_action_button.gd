extends Button

const attack_icon = preload("res://resources/sprites/icons/unit_action_icons/attack_icon.png")
const cancel_icon = preload("res://resources/sprites/icons/unit_action_icons/cancel_icon.png")
const interact_icon = preload("res://resources/sprites/icons/unit_action_icons/interact_icon.png")
const rescue_icon = preload("res://resources/sprites/icons/unit_action_icons/rescue_icon.png")
const shove_icon = preload("res://resources/sprites/icons/unit_action_icons/shove_icon.png")
const skill_icon = preload("res://resources/sprites/icons/unit_action_icons/skill_icon.png")
const support_icon = preload("res://resources/sprites/icons/unit_action_icons/support_icon.png")
const wait_icon = preload("res://resources/sprites/icons/unit_action_icons/wait_icon.png")
const trade_icon = preload("res://resources/sprites/icons/unit_action_icons/trade_icon.png")
const item_icon = preload("res://resources/sprites/icons/unit_action_icons/inventory_icon.png")
const demolish_icon = preload("res://resources/sprites/icons/unit_action_icons/demolish_icon.png")

func set_button(text:String):
	if CustomUtilityLibrary.equals_ignore_case(text, "Attack"):
		self.text = "Attack"
		self.icon = attack_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Support"):
		self.text = "Support"
		self.icon = support_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Demolish"):
		self.text = "Demolish"
		self.icon = demolish_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Skill"):
		self.text = "Skill"
		self.icon = skill_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Shove"):
		self.text = "Shove"
		self.icon = shove_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Rescue"):
		self.text = "Rescue"
		self.icon = rescue_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Interact"):
		self.text = "Interact"
		self.icon = interact_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Trade"):
		self.text = "Trade"
		self.icon = trade_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Item"):
		self.text = "Item"
		self.icon = item_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Wait"):
		self.text = "Wait"
		self.icon = wait_icon
	elif CustomUtilityLibrary.equals_ignore_case(text, "Cancel"):
		self.text = "Cancel"
		self.icon = cancel_icon


func _on_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")


func _on_focus_entered() -> void:
	AudioManager.play_sound_effect("menu_cursor")
