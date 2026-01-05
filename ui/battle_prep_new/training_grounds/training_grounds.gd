extends Control

class_name TrainingGrounds

signal return_to_menu()
signal award_exp(unit:CombatUnit, xp:int)
signal screen_change(state:TRAINING_STATE)

signal sell_item(value:int)
signal send_to_convoy(item)

@onready var training_grounds_container: HBoxContainer = $TrainingGroundsContainer

var playerOverworldData : PlayerOverworldData

enum TRAINING_STATE{
	CHOOSE_UNIT,GIVE_EXP
}

var chosen_unit : Unit

var current_state = TRAINING_STATE.CHOOSE_UNIT

func _ready() -> void:
	update_by_state()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		match current_state:
			TRAINING_STATE.CHOOSE_UNIT:
				return_to_menu.emit()
				queue_free()
			TRAINING_STATE.GIVE_EXP:
				current_state = TRAINING_STATE.CHOOSE_UNIT
				update_by_state()

func set_po_data(po_data):
	playerOverworldData = po_data

func update_by_state():
	clear_screen()
	screen_change.emit(current_state)
	match current_state:
		TRAINING_STATE.CHOOSE_UNIT:
			training_grounds_container.alignment = BoxContainer.ALIGNMENT_BEGIN
			var army_container = preload("res://ui/battle_prep_new/army_container/ArmyContainer.tscn").instantiate()
			army_container.set_po_data(playerOverworldData)
			army_container.set_units_list(playerOverworldData.total_party)
			army_container.unit_panel_pressed.connect(_on_unit_panel_pressed)
			army_container.sell_item.connect(_on_item_sold)
			army_container.send_to_convoy.connect(_on_send_to_convoy)
			if chosen_unit:
				army_container.focused = true
			training_grounds_container.add_child(army_container)
			army_container.fill_army_scroll_container()
			army_container.size_flags_vertical = SIZE_SHRINK_BEGIN
			if chosen_unit:
				army_container.get_unit_panel_from_container(chosen_unit).grab_focus()
		TRAINING_STATE.GIVE_EXP:
			training_grounds_container.alignment = BoxContainer.ALIGNMENT_CENTER
			var unit_level_info = preload("res://ui/battle_prep_new/training_grounds/unit_level_information/unit_level_info.tscn").instantiate()
			unit_level_info.unit = chosen_unit
			training_grounds_container.add_child(unit_level_info)
			unit_level_info.size_flags_vertical = SIZE_SHRINK_CENTER
			var bonus_experience_spend = preload("res://ui/battle_prep_new/training_grounds/bonus_experience_spend/bonus_experience_spend.tscn").instantiate()
			bonus_experience_spend.unit = chosen_unit
			bonus_experience_spend.available_bonus_exp = playerOverworldData.bonus_experience
			bonus_experience_spend.award_exp.connect(_on_award_xp.bind(unit_level_info))
			training_grounds_container.add_child(bonus_experience_spend)
			bonus_experience_spend.size_flags_vertical = SIZE_SHRINK_CENTER
			

func clear_screen():
	for child in training_grounds_container.get_children():
		child.queue_free()

func _on_unit_panel_pressed(unit:Unit):
	current_state = TRAINING_STATE.GIVE_EXP
	chosen_unit = unit
	update_by_state()

func _on_award_xp(unit:Unit, xp:int, bxp:int, level_info_screen):
	var comb = CombatUnit.create(unit, 0, 0,false,false)
	playerOverworldData.bonus_experience = bxp
	award_exp.emit(comb,xp)
	level_info_screen.update_by_unit()
	unit.set_hp_to_max()

func _on_item_sold(item:ItemDefinition):
	if item:
		#AudioManager.play_sound_effect("item_sell")
		#playerOverworldData.gold += item.worth/2
		#gold_counter.set_gold_count(playerOverworldData.gold)
		@warning_ignore("integer_division")
		sell_item.emit(item.worth/2)

func _on_send_to_convoy(item):
	send_to_convoy.emit(item)
