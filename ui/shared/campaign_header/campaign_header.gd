extends Control


@onready var gold_value_label: Label = $MainHeaderContainer/PanelContainer/MarginContainer/CampaignInfoContainer/CurrencyContainer/GoldContainer/GoldValueLabel
@onready var experience_value_label: Label = $MainHeaderContainer/PanelContainer/MarginContainer/CampaignInfoContainer/CurrencyContainer/ExperienceContainer/ExperienceValueLabel
@onready var floor_value_label: Label = $MainHeaderContainer/PanelContainer/MarginContainer/CampaignInfoContainer/FloorContainer/FloorValueLabel
@onready var difficulty_value_label: Label = $MainHeaderContainer/PanelContainer/MarginContainer/CampaignInfoContainer/DifficultyContainer/DifficultyValueLabel

@onready var artefact_icon_container: HBoxContainer = $MainHeaderContainer/ArtefactIconContainer


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
		CampaignModifier.DIFFICULTY.NORMAL:
			difficulty_text = "Normal"
		CampaignModifier.DIFFICULTY.HARD:
			difficulty_text = "Hard"
	difficulty_value_label.text = difficulty_text
