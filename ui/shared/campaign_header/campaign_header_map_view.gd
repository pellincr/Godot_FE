extends PanelContainer

@onready var gold_value_label: Label = $ObjectiveContainer/CurrencyContainer/GoldContainer/GoldValueLabel
@onready var floor_value_label: Label = $ObjectiveContainer/HBoxContainer/FloorContainer/FloorValueLabel
@onready var difficulty_value_label: Label = $ObjectiveContainer/HBoxContainer/DifficultyContainer/DifficultyValueLabel
@onready var experience_value_label: Label = $ObjectiveContainer/CurrencyContainer/ExperienceContainer/ExperienceValueLabel


func set_floor_value_label(value):
	floor_value_label.text = str(value)

func set_gold_value_label(value):
	gold_value_label.text = str(value)

func set_experience_value_label(value):
	experience_value_label.text = str(value)

func set_difficulty_value_label(value:CampaignModifier.DIFFICULTY):
	var difficulty_text = ""
	match value:
		CampaignModifier.DIFFICULTY.EASY:
			difficulty_text = "Easy"
		CampaignModifier.DIFFICULTY.HARD:
			difficulty_text = "Hard"
	difficulty_value_label.text = difficulty_text
