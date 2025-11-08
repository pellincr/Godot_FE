extends PanelContainer


@onready var campaign_name_label: Label = $MarginContainer/MainContainer/CampaignNameLabel
@onready var commander_limit_value: Label = $MarginContainer/MainContainer/CommanderLimitContainer/CommanderLimitValue
@onready var archetype_amount_value: Label = $MarginContainer/MainContainer/ArchetypeAmountContainer/ArchetypeAmountValue
@onready var floors_amount_value: Label = $MarginContainer/MainContainer/FloorAmountContainer/FloorsAmountValue
@onready var required_combat_amount_value: Label = $MarginContainer/MainContainer/RequiredCombatAmountContainer/RequiredCombatAmountValue


var campaign : Campaign

func _ready() -> void:
	if campaign:
		update_by_campaign()

func set_camoaign_name_label(n):
	campaign_name_label.text = n

func set_amount_value_label(label,amount):
	label.text = str(amount)

func update_by_campaign():
	set_camoaign_name_label(campaign.name)
	set_amount_value_label(commander_limit_value,campaign.commander_draft_limit)
	set_amount_value_label(archetype_amount_value,campaign.number_of_archetypes_drafted)
	set_amount_value_label(floors_amount_value,campaign.max_floor_number)
	set_amount_value_label(required_combat_amount_value,campaign.number_of_required_combat_maps)
