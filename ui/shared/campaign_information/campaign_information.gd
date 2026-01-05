extends Control

class_name CampaignInformation

signal menu_closed()

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var panel_container: PanelContainer = $CanvasLayer/PanelContainer
@onready var army_button: GeneralMenuButton = $CanvasLayer/PanelContainer/MarginContainer/InformationSelectionContainer/ArmyButton
@onready var convoy_button: GeneralMenuButton = $CanvasLayer/PanelContainer/MarginContainer/InformationSelectionContainer/ConvoyButton
@onready var campaign_map_button: GeneralMenuButton = $CanvasLayer/PanelContainer/MarginContainer/InformationSelectionContainer/CampaignMapButton


var playerOverworldData : PlayerOverworldData

enum STATE{
	SELECTION, ARMY, CONVOY, MAP
}

enum AVAILABILITY_STATE{
	UNAVAILABLE, FULL_AVAILABLE, MAP_ONLY, ARMY_CONVOY_ONLY
}

var current_state = STATE.SELECTION
var current_availabilty = AVAILABILITY_STATE.UNAVAILABLE

func _ready() -> void:
	update_by_availability()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("campaign_information") and current_availabilty != AVAILABILITY_STATE.UNAVAILABLE:
		if current_state != STATE.SELECTION:
			set_state(STATE.SELECTION)
		else:
			menu_closed.emit()
	if (event.is_action_pressed("ui_back") or event.is_action_pressed("ui_cancel")):
		if current_state != STATE.SELECTION:
			set_state(STATE.SELECTION)
		else:
			menu_closed.emit()


func set_po_data(po_data):
	playerOverworldData = po_data

func update_by_availability():
	match current_availabilty:
		AVAILABILITY_STATE.UNAVAILABLE:
			pass
		AVAILABILITY_STATE.FULL_AVAILABLE:
			army_button.grab_focus()
		AVAILABILITY_STATE.MAP_ONLY:
			campaign_map_button.grab_focus()
			army_button.visible = false
			convoy_button.visible = false
		AVAILABILITY_STATE.ARMY_CONVOY_ONLY:
			army_button.grab_focus()
			campaign_map_button.visible = false

func set_state(state:STATE):
	current_state = state
	update_by_state()


func update_by_state():
	if current_state == STATE.SELECTION:
		canvas_layer.get_child(-1).queue_free()
	match current_state:
		STATE.SELECTION:
			panel_container.visible = true
			army_button.grab_focus()
		STATE.ARMY:
			panel_container.visible = false
			var army_container = preload("res://ui/battle_prep_new/army_container/ArmyContainer.tscn").instantiate()
			army_container.set_po_data(playerOverworldData)
			canvas_layer.add_child(army_container)
			army_container.set_units_list(playerOverworldData.total_party)
			army_container.fill_army_scroll_container()
		STATE.CONVOY:
			panel_container.visible = false
			var convoy_container = preload("res://ui/battle_prep_new/convoy/convoy_container/convoy_container.tscn").instantiate()
			convoy_container.set_po_data(playerOverworldData)
			canvas_layer.add_child(convoy_container)
			convoy_container.fill_convoy_scroll_container()


func _on_army_button_pressed() -> void:
	set_state(STATE.ARMY)


func _on_convoy_button_pressed() -> void:
	set_state(STATE.CONVOY)
