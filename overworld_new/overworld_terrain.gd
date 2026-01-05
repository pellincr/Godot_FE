extends Node2D

signal campaign_selected(campaign:Campaign)

@onready var test_campaign_button: Button = $ObjectLayer/TestCampaignButton

func _ready() -> void:
	grab_button_focus()

func grab_button_focus():
	test_campaign_button.grab_focus()


func _on_campaign_button_selected(campaign: Variant) -> void:
	campaign_selected.emit(campaign)
