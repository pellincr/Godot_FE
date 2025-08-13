extends MarginContainer

@onready var end_turn_btn: Button = $Vbox/endTurn
@onready var overview_btn: Button = $Vbox/overview
@onready var campaign_btn: Button = $Vbox/campaign
@onready var cancel_btn: Button = $Vbox/cancel


func _ready():
	end_turn_btn.grab_focus()
