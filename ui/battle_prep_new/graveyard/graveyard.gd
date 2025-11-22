extends Control

class_name Graveyard

signal return_to_menu()
signal screen_change(STATE)
signal unit_revived(cost)

var playerOverworldData : PlayerOverworldData

enum STATE {
	SELECT_UNIT, CHOOSE_REVIVE
}
var current_state = STATE.SELECT_UNIT

var chosen_unit : Unit

func _ready() -> void:
	update_by_state()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		match current_state:
			STATE.SELECT_UNIT:
				return_to_menu.emit()
				queue_free()
			STATE.CHOOSE_REVIVE:
				current_state = STATE.SELECT_UNIT
				update_by_state()

func set_po_data(po_data):
	playerOverworldData = po_data

func clear_screen():
	for child in get_children():
		if child is not TextureRect:
			child.queue_free()

func update_by_state():
	clear_screen()
	screen_change.emit(current_state)
	match current_state:
		STATE.SELECT_UNIT:
			var army_container = preload("res://ui/battle_prep_new/army_container/ArmyContainer.tscn").instantiate()
			army_container.set_po_data(playerOverworldData)
			army_container.set_units_list(playerOverworldData.dead_party_members)
			add_child(army_container)
			army_container.fill_army_scroll_container()
			army_container.unit_panel_pressed.connect(_on_unit_panel_pressed)
		STATE.CHOOSE_REVIVE:
			var tombstone = preload("res://ui/battle_prep_new/graveyard/tombstone/tombstone.tscn").instantiate()
			tombstone.unit = chosen_unit
			add_child(tombstone)
			tombstone.unit_revived.connect(_on_unit_revived)
			tombstone.position = Vector2(540,210)

func _on_unit_panel_pressed(unit:Unit):
	chosen_unit = unit
	current_state = STATE.CHOOSE_REVIVE
	update_by_state()

func _on_unit_revived(unit:Unit, cost:int):
	if playerOverworldData.gold >= cost:
		AudioManager.play_sound_effect("resurrect")
		unit_revived.emit(cost)
		playerOverworldData.total_party.append(unit)
		playerOverworldData.dead_party_members.erase(unit)
		current_state = STATE.SELECT_UNIT
		update_by_state()
