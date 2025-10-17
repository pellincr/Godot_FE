extends PanelContainer
signal gold_obtained(gold:int)
signal bonus_exp_obtained(b_exp:int)
signal rewards_complete()

@onready var overall_grade_label: Label = $MarginContainer/MainContainer/MainGradeContainer/OverallGradeContainer/OverallGradeLabel
@onready var turn_grade_label: Label = $MarginContainer/MainContainer/MainGradeContainer/TurnCountGradeContainer/TurnGradeLabel
@onready var survival_grade_label: Label = $MarginContainer/MainContainer/MainGradeContainer/SurvivalGradeContainer/SurvivalGradeLabel

@onready var main_button_container: VBoxContainer = $MarginContainer/MainContainer/MainButtonContainer
@onready var gold: Button = $MarginContainer/MainContainer/MainButtonContainer/Gold
@onready var bonus_exp: Button = $MarginContainer/MainContainer/MainButtonContainer/BonusExp


var reward : CombatReward


func _ready() -> void:
	gold.grab_focus()
	#reward = CombatReward.new()
	#reward.base_bonus_exp = 100
	#reward.base_gold = 100
	#reward.par_turns = 8
	#reward.turns_survived = 7
	#reward.units_allowed = 4
	#reward.units_lost = 2
	#reward.calculate_turn_grade()
	#reward.calculate_survival_grade()
	#reward.calculate_overall_grade()
	#reward.calculate_reward()
	if reward:
		update_by_reward()


func update_grade_label(label:Label,grade:CombatReward.GRADE):
	label.text = reward.grade_string(grade)

func update_gold_button_text(gld):
	gold.text = "Gold:" + str(gld)

func update_bonus_exp_button_text(bexp):
	bonus_exp.text = "Bonus Exp: " + str(bexp)

func update_by_reward():
	update_grade_label(overall_grade_label,reward.overall_grade)
	update_grade_label(turn_grade_label,reward.turn_grade)
	update_grade_label(survival_grade_label,reward.survival_grade)
	update_gold_button_text(reward.reward_gold)
	update_bonus_exp_button_text(reward.reward_bonus_exp)


func update_buttons(pressed_button):
	pressed_button.queue_free()
	if main_button_container.get_child_count() > 1:
		#If there are still rewards to collect
		for child in main_button_container.get_children():
			if !child == pressed_button:
				child.grab_focus()
	else:
		#if there are no more rewards to collect
		_on_skip_rewards_pressed()

func _on_gold_pressed() -> void:
	gold_obtained.emit(reward.reward_gold)
	update_buttons(gold)


func _on_bonus_exp_pressed() -> void:
	bonus_exp_obtained.emit(reward.reward_bonus_exp)
	update_buttons(bonus_exp)

func _on_skip_rewards_pressed() -> void:
	queue_free()
	rewards_complete.emit()
