extends Control

signal turn_ended()
signal unit_experience_ended()

@export var combat: Combat
@export var controller: CController
@export var ui_map_audio : AudioStreamPlayer
@export var ui_menu_audio : AudioStreamPlayer

@export var active_ui_node : Node

#Scene Imports
const tradeContainer = preload("res://ui/combat/unit_trade/trade_container.tscn")
const inventoryOptionsContainer = preload("res://ui/combat/option_container/inventory_options_container.tscn")
const UnitActionContainer = preload("res://ui/combat/unit_action_container/unit_action_container.tscn")
#Audio imports
const menu_back_sound = preload("res://resources/sounds/ui/menu_back.wav")
const menu_confirm_sound = preload("res://resources/sounds/ui/menu_confirm.wav")
const cursor_sound = preload("res://resources/sounds/ui/menu_cursor.wav")

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

func _ready():
	transition_in_animation()
	ui_map_audio = $UIMapAudio
	ui_menu_audio = $UIMenuAudio
	#signal wiring
	combat.connect("update_combatants", update_combatants)
	combat.connect("update_information", update_information)
	controller.connect("target_detailed_info", _target_detailed_info)

func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.set_label_text(playerOverworldData.current_campaign.name + " - Level " + str(playerOverworldData.current_level + 1))
	scene_transition.play_animation("level_fade_out")
	await get_tree().create_timer(5).timeout
	scene_transition.queue_free()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func create_unit_action_container(available_actions:Array[String]):
	var unit_action_container = UnitActionContainer.instantiate()
	unit_action_container.populate(available_actions, controller)
	self.add_child(unit_action_container)
	active_ui_node = unit_action_container
	unit_action_container.grab_focus()

func destory_active_ui_node():
	active_ui_node.queue_free()

func target_selected(info: Dictionary): 
	populate_combat_info(info)
	
func populate_combat_info(info: Dictionary):
	var attacker_info_name= $Actions/CombatInfo/Container/ActionsGrid/AttackerInfo/Name
	attacker_info_name.text = info.attacker_name
	##populate attack stats
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/HP.text = info.attacker_hp
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/Damage.text = info.attacker_damage
	$Actions/CombatInfo/Container/ActionsGrid/AttackerStats/Hit.text = info.attacker_hit_chance
	##populate defender stats
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/HP.text = info.defender_hp
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/Damage.text = info.defender_damage
	$Actions/CombatInfo/Container/ActionsGrid/DefenderStats/Hit.text = info.defender_hit_chance

func _on_end_turn_button_pressed():
	print("End Turn Button pressed")
	turn_ended.emit()

func update_information(info: String):
	$Actions/Information/Text.append_text(info)

func clear_action_button_connections(action: Button):
	var connections = action.pressed.get_connections()
	for connection in connections:
		action.pressed.disconnect(connection.callable)

func update_combatants(combatants: Array):
	for comb in combatants:
		if comb.allegience == 0:
			var status = $Status.find_child(comb.unit.name, false, false)
			if status != null:
				status.set_health(comb.hp, comb.stats.hp)
		var turn_queue_icon = $TurnQueue/Queue.get_node(comb.unit.name)
		if turn_queue_icon != null:
			turn_queue_icon.set_hp(comb.unit.hp)
			turn_queue_icon.set_side(comb.allegience)
			turn_queue_icon.set_turn_taken(comb.turn_taken)

func hide_action_list():
	var actions_grid_children = $Actions/ActionsPanel/ActionsMenu.get_children()
	$Actions/ActionsPanel.visible = false
	
func set_action_list(available_actions: Array[UnitAction]):
	var actions_grid_children = $Actions/ActionsPanel/ActionsMenu.get_children()
	actions_grid_children[0].grab_focus()
	$Actions/ActionsPanel.visible = true
	var player_turn = controller.player_turn
	for i in range(actions_grid_children.size()):
		var action_btn = actions_grid_children[i] as Button
		if player_turn == false:
			##action.disabled = true
			continue
		else:
			action_btn.disabled = false
		if available_actions.size() > i:
			action_btn.visible = true
			var action = available_actions[i]
			#action.icon = skill.icon
			action_btn.text = action.name
			action_btn.pressed.connect(func():
				play_menu_confirm()
				controller.set_unit_action(action)
				#controller.begin_target_selection()
				controller.begin_action_flow()
				)
		else:
			action_btn.visible = false
			action_btn.icon = null
			action_btn.text = ""
			action_btn.tooltip_text = ""
			clear_action_button_connections(action_btn)
	actions_grid_children[0].grab_focus()
	$Actions/EndTurnButton.disabled = !player_turn

func set_inventory_list_attack(unit: Unit, weaponList:Array[WeaponDefinition] = []):
	print("@# set_inventory_list_attack called")
	var attack_action_inventory = $AttackActionInventory
	attack_action_inventory.show_equippable_item_info()
	attack_action_inventory.set_unit(unit)
	var inventory_container_children = attack_action_inventory.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = false
			clear_action_button_connections(item_btn)
			var weapon_list = []
			if weaponList.is_empty():
				weapon_list = unit.get_equippable_weapons()
			else:
				weapon_list = weaponList.duplicate()
			if not weapon_list.is_empty():
				if weapon_list.size() > i:
					var item = weapon_list[i]
					if item.item_target_faction.has(itemConstants.AVAILABLE_TARGETS.ENEMY):
						var equipped = false
						if i == 0: 
							equipped = true
						inventory_container_children[i].set_all(item, equipped)
						inventory_container_children[i].visible = true
						item_btn.pressed.connect(func():
							play_menu_confirm()
							controller.set_selected_item(item)
							controller.action_item_selected()
							)
					else: 
						inventory_container_children[i].visible = false
						clear_action_button_connections(item_btn)
				else : 
					inventory_container_children[i].visible = false
					clear_action_button_connections(item_btn)
	var test = inventory_container_children[0]
	test.grab_button_focus()

func set_inventory_list_support(unit: Unit):
	print("set_inventory_list_support")
	var attack_action_inventory = $AttackActionInventory
	attack_action_inventory.set_unit(unit)
	attack_action_inventory.hide_equippable_item_info()
	var inventory_container_children = attack_action_inventory.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = false
			clear_action_button_connections(item_btn)
			var weapon_list = unit.get_equippable_weapons()
			if not weapon_list.is_empty():
				
				if weapon_list.size() > i:
					var item = weapon_list[i]
					if item.item_target_faction.has(itemConstants.AVAILABLE_TARGETS.ALLY):
						var equipped = false
						if i == 0: 
							equipped = true
						inventory_container_children[i].set_all(item, equipped)
						inventory_container_children[i].visible = true
						
						item_btn.pressed.connect(func():
							play_menu_confirm()
							controller.set_selected_item(item)
							
							controller.action_item_selected()
							)
					else : 
						inventory_container_children[i].visible = false
						clear_action_button_connections(item_btn)
				else : 
					inventory_container_children[i].visible = false
					clear_action_button_connections(item_btn)
	var test = inventory_container_children[0]
	test.grab_button_focus()

func set_inventory_list_item_select(u: Unit, items: Array[ItemDefinition]):
	print("set_inventory_list_support")
	var  action_inv = $ActionInventory
	
	var inventory_container_children = action_inv.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = false
			clear_action_button_connections(item_btn)
			if not items.is_empty():
				if items.size() > i:
					var item = items[i]
					inventory_container_children[i].set_all(item)
					inventory_container_children[i].visible = true
					item_btn.pressed.connect(func():
						play_menu_confirm()
						controller.set_selected_item(item)
						controller.action_item_selected()
						)
				else : 
					inventory_container_children[i].visible = false
					clear_action_button_connections(item_btn)
	var test = inventory_container_children[0]
	test.grab_button_focus()

func set_inventory_list(unit: Unit):
	print("@# set_inventory_list called")
	var attack_action_inventory:  = $AttackActionInventory
	attack_action_inventory.show_equippable_item_info()
	attack_action_inventory.set_unit(unit)
	var inventory_container_children = attack_action_inventory.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = false
			clear_action_button_connections(item_btn)
			var item_list = unit.inventory.items
			if not item_list.is_empty():
				if item_list.size() > i:
					var item = item_list[i]
					var equipped = false
					if i == 0: 
						equipped = true
					inventory_container_children[i].set_all(item, equipped)
					inventory_container_children[i].visible = true
					item_btn.pressed.connect(func():
						play_menu_confirm()
						controller.set_selected_item(item)
						controller.action_item_selected()
						create_inventory_options_container(unit, item, attack_action_inventory)
						)
				else : 
					inventory_container_children[i].visible = false
					clear_action_button_connections(item_btn)

func create_inventory_options_container(unit:Unit, item: ItemDefinition, parent: Node):
	var inv_op_con = inventoryOptionsContainer.instantiate()
	parent.add_child(inv_op_con)
	inv_op_con.position = Vector2(0,0)
	var btn_1 : Button = inv_op_con.get_button1()
	var btn_2 : Button = inv_op_con.get_button2()
	if item is WeaponDefinition:
		btn_1.text = "Equip"
		btn_1.disabled = not unit.can_equip(item)
		btn_1.pressed.connect(func():
			unit.set_equipped(item)
			play_menu_confirm()
			set_inventory_list(unit)
			inv_op_con.queue_free())
	if item is ConsumableItemDefinition:
		btn_1.text = "Use"
		btn_1.disabled = not unit.can_use_consumable_item(item)
		btn_1.pressed.connect(func(): 
			controller.set_unit_action(controller.use_action)
			controller.use_action_selected()
			#controller.combat.Use_Consumable_Item(item)
			play_menu_confirm()
			inv_op_con.queue_free())
	btn_2.text = "Discard"
	btn_2.pressed.connect(func():
		unit.discard_item(item)
		play_menu_confirm()
		set_inventory_list(unit)
		inv_op_con.queue_free())

func remove_inventory_options_container():
	var a_a_i = $AttackActionInventory
	var children = a_a_i.get_children()
	for child in children:
		if child is IventoryOptionsContainer :
			child.queue_free()
	enable_inventory_list_butttons()

func disable_inventory_list_butttons():
	var attack_action_inventory = $AttackActionInventory
	var inventory_container_children = attack_action_inventory.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = true
			item_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

func enable_inventory_list_butttons():
	var attack_action_inventory = $AttackActionInventory
	var inventory_container_children = attack_action_inventory.get_inventory_container_children()
	for i in range(inventory_container_children.size()):
		if inventory_container_children[i] is UnitInventorySlot:
			var item_btn = inventory_container_children[i].get_button() as Button
			item_btn.disabled = false
			item_btn.mouse_filter = Control.MOUSE_FILTER_STOP

func set_movement(movement):
	$Actions/Movement.text = str(movement)


func _target_selection_finished():
	$Actions/SelectTargetMessage.visible = false


func _target_selection_started():
	$Actions/SelectTargetMessage.visible = true

func _target_detailed_info(combat_unit: CombatUnit):
	if combat_unit:
		if not $UnitStatusDetailed.visible :
			$UnitStatusDetailed.set_unit(combat_unit)
			$UnitStatusDetailed.visible = true
	else :
		$UnitStatusDetailed.visible = false	
		$AttackActionInventory.visible = false
	

func _set_tile_info(tile : CombatMapTile, unit:CombatUnit) :
	$combat_tile_info.set_all(tile.terrain, tile.position.x,tile.position.y)
	if(unit):
		$UnitStatus.set_unit(tile.unit)
		$UnitStatus.visible = true
	else:
		$UnitStatus.visible = false

func _set_attack_action_inventory(combat_unit: CombatUnit, weaponList : Array[WeaponDefinition] = []) -> void:
	set_inventory_list_attack(combat_unit.unit, weaponList)
	if $AttackActionInventory.visible == false :
		$AttackActionInventory.visible = true 

func _set_support_action_inventory(combat_unit: CombatUnit) -> void:
	set_inventory_list_support(combat_unit.unit)
	if $AttackActionInventory.visible == false :
		$AttackActionInventory.visible = true 

func _set_item_action_inventory(combat_unit: CombatUnit, items:Array[ItemDefinition]) -> void:
	set_inventory_list_item_select(combat_unit.unit, items)
	if $ActionInventory.visible == false :
		$ActionInventory.visible = true 


func _set_inventory_list(combat_unit: CombatUnit) -> void:
	set_inventory_list(combat_unit.unit)
	if $AttackActionInventory.visible == false :
		$AttackActionInventory.visible = true 

func hide_attack_action_inventory():
	$AttackActionInventory.visible = false 

func hide_action_inventory():
	$ActionInventory.visible = false 


func display_unit_combat_exchange_preview(combat_unit_a: CombatUnit, combat_unit_d: CombatUnit, distance:int):
	$unit_combat_exchange_preview.set_all(combat_unit_a,combat_unit_d,distance)
	$unit_combat_exchange_preview.visible = true

func hide_unit_combat_exchange_preview():
	$unit_combat_exchange_preview.visible = false

func display_unit_experience_bar(u : Unit):
	$unit_experience_bar.set_reference_unit(u)
	$unit_experience_bar.visible = true

func unit_experience_bar_gain(value: int):
	$unit_experience_bar.update_xp(value)
	await $unit_experience_bar.finished
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")
	
func hide_unit_experience_bar():
	$unit_experience_bar.visible = false

func play_cursor():
	play_audio(cursor_sound, ui_map_audio)

func play_menu_confirm():
	play_audio(menu_confirm_sound, ui_menu_audio)
	
func play_menu_back():
	play_audio(menu_back_sound, ui_menu_audio)

func play_audio(sound : AudioStream, audio_source: AudioStreamPlayer):
	audio_source.stream = sound
	audio_source.play()
	await audio_source.finished


func _on_unit_experience_bar_finished() -> void:
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")

func hide_end_turn_button():
		$Actions/EndTurnButton.visible = false

func show_end_turn_button():
		$Actions/EndTurnButton.visible = true

func show_trade_container(ua,ub):
	var tc : TradeContainer = tradeContainer.instantiate()
	await tc
	tc.set_unit_a(ua.unit)
	tc.set_unit_b(ub.unit)
	tc.update_trade_inventories()
	self.add_child(tc)

func destroy_trade_container():
	var children = self.get_children()
	for child in children:
		if child is TradeContainer:
			child.queue_free()
			return
