extends PanelContainer

signal award_exp(unit:Unit, xp:int, bxp:int)

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
	return floor(full_level_up_amount * (float(xp)/100))

func bonus_experience_to_experience(bxp,lv):
	var full_level_up_amount = (50 * lv) + 50
	return 100 * (float(bxp)/full_level_up_amount)

func _on_experience_gained_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if experience_gained > 0:
			award_exp.emit(unit, experience_gained, available_bonus_exp)
			spend_bonus_exp()
			AudioManager.play_sound_effect("bonus_experience_spend")
	if event.is_action_pressed("ui_up"):
		increase_exp_gain_one()
		AudioManager.play_sound_effect("bonus_experience_point")
	if event.is_action_pressed("ui_down"):
		decrease_exp_gain_one()
		AudioManager.play_sound_effect("bonus_experience_point")
	if event.is_action_pressed("ui_left"):
		decrease_exp_gain_ten()
		AudioManager.play_sound_effect("bonus_experience_point")
	if event.is_action_pressed("ui_right"):
		increase_exp_gain_ten()
		AudioManager.play_sound_effect("bonus_experience_point")
	if event.is_action_pressed("right_bumper"):
		jump_to_next_level()
		AudioManager.play_sound_effect("bonus_experience_point")
	if event.is_action_pressed("left_bumper"):
		decrease_exp_gain_n(experience_gained)
		AudioManager.play_sound_effect("bonus_experience_point")
"""
#Increases the Exp Gain Value by the N Value if there is enough bonus exp to satisfy
func increase_exp_gain_n(n:int):
	var current_level := unit.level
	#Calculate the level to base the bonus_exp scaling off of
	if unit.experience + experience_gained >= 100:
		#if the Given exp is enough to cause a level up
		current_level += 1
	
	if available_bonus_exp >= experience_to_bonus_experience(n+experience_gained,current_level) and experience_gained < 100:
		available_bonus_exp -= experience_to_bonus_experience(experience_gained+n,current_level) - experience_to_bonus_experience(experience_gained,current_level)
		set_bonus_experience_value_label(available_bonus_exp)
		experience_gained += n
		set_experience_gain_value_label(experience_gained)
		set_experience_value_label(unit.experience + experience_gained)
		if unit.experience + experience_gained >= 100:
			#If after increasing, the unit would have leveled up
			show_level_increase_icon()
			set_level_value_label(unit.level + 1)
			set_experience_value_label(unit.experience + experience_gained - 100)
"""
func increase_exp_gain_n(n: int) -> void:
	var base_level := unit.level
	var base_exp := unit.experience % 100
	var old_experience_gained := experience_gained
	var new_experience_gained := experience_gained + n

	# Clamp to a reasonable range (e.g., can’t gain more than 100 in one go)
	new_experience_gained = clamp(new_experience_gained, 0, 9999) # adjust max if needed

	# Compute total bonus before and after the increase
	var prev_total_bonus := compute_total_bonus_for_gain(old_experience_gained, base_level, base_exp)
	var new_total_bonus := compute_total_bonus_for_gain(new_experience_gained, base_level, base_exp)

	# The extra bonus required for this increment
	var bonus_delta := new_total_bonus - prev_total_bonus

	# Check if there’s enough available bonus exp to pay for the increase
	if available_bonus_exp >= bonus_delta and experience_gained < 100:
		available_bonus_exp -= bonus_delta
		experience_gained = new_experience_gained

		set_bonus_experience_value_label(available_bonus_exp)
		set_experience_gain_value_label(experience_gained)

		# Compute new total exp to determine if level-up occurs
		var total_after := base_exp + experience_gained
		var levels_gained := int(total_after / 100)

		if total_after < 100:
			hide_level_increase_icon()
			set_level_value_label(base_level)
			set_experience_value_label(total_after)
		else:
			show_level_increase_icon()
			set_level_value_label(base_level + levels_gained)
			set_experience_value_label(total_after % 100)

func increase_exp_gain_one():
	increase_exp_gain_n(1)

func increase_exp_gain_ten():
	if experience_gained <= 90:
		increase_exp_gain_n(10)


# Helper: compute total bonus for a given gained experience amount,
# starting from `start_level` and `start_exp` (0..99).
func compute_total_bonus_for_gain(exp_gain: int, start_level: int, start_exp: int) -> int:
	var total_bonus := 0
	var remaining = max(0, exp_gain)
	var curr_level := start_level
	var curr_exp := start_exp % 100

	while remaining > 0:
		var to_next_level := 100 - curr_exp          # exp needed to reach next level
		var chunk = min(remaining, to_next_level)  # how much of the gain applies at this level
		if chunk > 0:
			# call your original function for the chunk at the correct level
			total_bonus += experience_to_bonus_experience(chunk, curr_level)
			remaining -= chunk
		# we consumed 'chunk'; if there is still remaining, that means we leveled up
		if remaining > 0:
			curr_level += 1
			curr_exp = 0
		else:
			# consumed all gain, update current exp (not strictly needed here)
			curr_exp = (curr_exp + chunk) % 100
	# end while
	return total_bonus

# Main function: decrease the displayed experience gain by n and correctly adjust bonus.
func decrease_exp_gain_n(n: int) -> void:
	# old values before changing experience_gained
	var old_experience_gained := experience_gained
	var base_level := unit.level
	var base_exp := unit.experience % 100

	# compute previous total bonus (what the UI was assuming before the decrement)
	var prev_total_bonus := compute_total_bonus_for_gain(old_experience_gained, base_level, base_exp)

	# actually decrement the gained experience
	experience_gained = max(0, experience_gained - n)

	# compute new total bonus after the decrement
	var new_total_bonus := compute_total_bonus_for_gain(experience_gained, base_level, base_exp)

	# adjust available bonus by the difference (prev - new). If positive, we add that many freed bonus points.
	var bonus_delta := prev_total_bonus - new_total_bonus
	available_bonus_exp += bonus_delta
	set_bonus_experience_value_label(available_bonus_exp)

	# update the displayed experience gain and raw experience value
	set_experience_gain_value_label(experience_gained)

	# compute total experience to determine level indicator and displayed exp
	var total_after := base_exp + experience_gained
	var levels_gained := int(total_after / 100)
	if total_after < 100:
		# not leveled up
		hide_level_increase_icon()
		set_level_value_label(base_level)
		set_experience_value_label(total_after)
	else:
		# leveled up (could be +1 or more)
		show_level_increase_icon()
		set_level_value_label(base_level + levels_gained)
		set_experience_value_label(total_after)



func decrease_exp_gain_one():
	decrease_exp_gain_n(1)

func decrease_exp_gain_ten():
	if experience_gained >= 10:
		decrease_exp_gain_n(10)
	else:
		decrease_exp_gain_n(experience_gained)

func jump_to_next_level():
	var current_level := unit.level#2
	var current_exp := unit.experience # 35  
	var remaining_exp = 100 - current_exp #75
	var remaining_exp_cost := experience_to_bonus_experience(remaining_exp ,current_level) 	
	if remaining_exp > experience_gained:
		#If experience needs to be added to the tracker
		var exp_needed = remaining_exp - experience_gained #75 - 25 = 50
		if available_bonus_exp >= remaining_exp_cost:
			#If there is enough available bonus exp to cover the entirety of the cost, increase by the total
			increase_exp_gain_n(exp_needed)
		else:
			#If there is not enough available bonus exp needed to cover the cost, convert what can be spent and increase it
			var remaining_bonusxp_as_xp = bonus_experience_to_experience(available_bonus_exp,current_level)
			increase_exp_gain_n(remaining_bonusxp_as_xp)
	else:
		#If experience needs to be subtracted from the tracker
		#var full_level_exp = experience_to_bonus_experience(100,current_level)
		decrease_exp_gain_n(experience_gained - remaining_exp)



func spend_bonus_exp():
	experience_gained = 0
	hide_level_increase_icon()
	set_experience_gain_value_label(experience_gained)
	#set_level_value_label(unit.level)
