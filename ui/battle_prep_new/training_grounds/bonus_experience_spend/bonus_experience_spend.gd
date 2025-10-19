extends PanelContainer

signal award_exp(unit:Unit, xp:int)

@onready var bonus_experience_value_label: Label = $MarginContainer/VBoxContainer/BonusExperienceContainer/BonusExperienceValueLabel

@onready var experience_gained_panel: PanelContainer = $MarginContainer/VBoxContainer/ExperienceGainContainer/ExperienceGainedPanel
@onready var experience_gain_value_label: Label = $MarginContainer/VBoxContainer/ExperienceGainContainer/ExperienceGainedPanel/ExperienceGainValueLabel


@onready var level_value_label: Label = $MarginContainer/VBoxContainer/ExperienceGainContainer/LevelContainer/LevelValueLabel
@onready var level_increase_icon: TextureRect = $MarginContainer/VBoxContainer/ExperienceGainContainer/LevelContainer/LevelIncreaseIcon

@onready var experience_value_label: Label = $MarginContainer/VBoxContainer/ExperienceGainContainer/ExperienceContainer/ExperienceValueLabel

var unit : Unit
var available_bonus_exp : int
var experience_gained := 0

func _ready():
	experience_gained_panel.grab_focus()
	if unit:
		update_by_unit()
	if available_bonus_exp:
		set_bonus_experience_value_label(available_bonus_exp)


func update_by_unit():
	set_level_value_label(unit.level)
	set_experience_value_label(unit.experience)

func set_bonus_experience_value_label(bonus_exp):
	bonus_experience_value_label.text = str(bonus_exp)

func set_experience_gain_value_label(gained_exp):
	experience_gain_value_label.text = "+" + str(gained_exp)

func set_level_value_label(lv):
	level_value_label.text = str(lv)

func show_level_increase_icon():
	level_increase_icon.visible = true

func hide_level_increase_icon():
	level_increase_icon.visible = false

func set_experience_value_label(gain_exp):
	experience_value_label.text = str(gain_exp)

func experience_to_bonus_experience(xp, lv) -> int:
	var full_level_up_amount = (50 * lv) + 50
	return full_level_up_amount * (float(xp)/100)

func _on_experience_gained_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if experience_gained > 0:
			award_exp.emit(unit, experience_gained)
			spend_bonus_exp()
	if event.is_action_pressed("ui_up"):
		increase_exp_gain_one()
	if event.is_action_pressed("ui_down"):
		decrease_exp_gain_one()
	if event.is_action_pressed("ui_left"):
		decrease_exp_gain_ten()
	if event.is_action_pressed("ui_right"):
		increase_exp_gain_ten()
	if event.is_action_pressed("right_bumper"):
		jump_to_next_level()
	if event.is_action_pressed("left_bumper"):
		decrese_exp_gain_n(experience_gained)

#Increases the Exp Gain Value by the N Value if there is enough bonus exp to satisfy
func increase_exp_gain_n(n:int):
	var current_level := unit.level
	#Calculate the level to base the bonus_exp scaling off of
	if unit.experience + experience_gained >= 100:
		#if the Given exp is enough to cause a level up
		current_level += 1
	
	if available_bonus_exp >= experience_to_bonus_experience(n,current_level) and experience_gained <= 100:
		experience_gained += n
		set_experience_gain_value_label(experience_gained)
		set_experience_value_label(unit.experience + experience_gained)
		available_bonus_exp -= experience_to_bonus_experience(n,current_level)
		set_bonus_experience_value_label(available_bonus_exp)
		if unit.experience + experience_gained >= 100:
			#If after increasing, the unit would have leveled up
			show_level_increase_icon()
			set_level_value_label(unit.level + 1)
			set_experience_value_label(unit.experience + experience_gained - 100)


func increase_exp_gain_one():
	increase_exp_gain_n(1)

func increase_exp_gain_ten():
	increase_exp_gain_n(10)

func decrese_exp_gain_n(n:int):
	var current_level := unit.level
	if unit.experience + experience_gained - n >= 100:
		#if the Given exp is enough to cause a level up
		current_level += 1
	
	if experience_gained > 0:
		experience_gained -= n
		set_experience_gain_value_label(experience_gained)
		available_bonus_exp += experience_to_bonus_experience(n,current_level)
		set_bonus_experience_value_label(available_bonus_exp)
		if unit.experience + experience_gained <= 100:
			#If after decreasing, the unit would no longer have leveled up
			hide_level_increase_icon()
			set_level_value_label(unit.level)
			set_experience_value_label(unit.experience + experience_gained)
		else:
			set_experience_value_label(unit.experience + experience_gained - 100)

func decrease_exp_gain_one():
	decrese_exp_gain_n(1)

func decrease_exp_gain_ten():
	if experience_gained >= 10:
		decrese_exp_gain_n(10)
	else:
		decrese_exp_gain_n(experience_gained)

func jump_to_next_level():
	var current_level := unit.level
	var current_exp := unit.experience
	var remaining_exp = 100 - current_exp
	var remaining_exp_cost := experience_to_bonus_experience(remaining_exp,current_level)
	if remaining_exp_cost > experience_gained:
		increase_exp_gain_n(min(remaining_exp_cost-experience_gained,available_bonus_exp))
	else:
		var full_level_exp = experience_to_bonus_experience(100,current_level)
		decrese_exp_gain_n(experience_gained - full_level_exp)

func spend_bonus_exp():
	experience_gained = 0
	hide_level_increase_icon()
	set_experience_gain_value_label(experience_gained)
	#set_level_value_label(unit.level)
