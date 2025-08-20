extends Control

signal turn_ended()
signal unit_experience_ended()

@export var combat: Combat
@export var controller: CController
@export var ui_map_audio : AudioStreamPlayer
@export var ui_menu_audio : AudioStreamPlayer

@export var active_ui_node : Node

#Scene Imports
#Menu
const COMBAT_MAP_MENU = preload("res://ui/combat/combat_map_menu/combat_map_menu.tscn")
const COMBAT_MAP_CAMPAIGN_MENU = preload("res://ui/combat/combat_map_menu/combat_map_campaign_menu.tscn")

#Combat Action
const ATTACK_ACTION_INVENTORY = preload("res://ui/combat/attack_action_inventory/attack_action_inventory.tscn")
const UNIT_COMBAT_EXCHANGE_PREVIEW = preload("res://ui/combat/combat_exchange_preview/unit_combat_exchange_preview.tscn")

#Support Action
const SUPPORT_ACTION_INVENTORY = preload("res://ui/combat/support_action_inventory/support_action_inventory.tscn")

#Trade Action
const tradeContainer = preload("res://ui/combat/unit_trade/trade_container.tscn")
const inventoryOptionsContainer = preload("res://ui/combat/option_container/inventory_options_container.tscn")
const UnitActionContainer = preload("res://ui/combat/unit_action_container/unit_action_container.tscn")

#Audio imports
const menu_back_sound = preload("res://resources/sounds/ui/menu_back.wav")
const menu_confirm_sound = preload("res://resources/sounds/ui/menu_confirm.wav")
const cursor_sound = preload("res://resources/sounds/ui/menu_cursor.wav")

#transition
const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

@onready var playerOverworldData:PlayerOverworldData = ResourceLoader.load(SelectedSaveFile.selected_save_path + "PlayerOverworldSave.tres").duplicate(true)

func _ready():
	transition_in_animation()
	ui_map_audio = $UIMapAudio
	ui_menu_audio = $UIMenuAudio
	#signal wiring
	#combat.connect("update_combatants", update_combatants) ## THIS IS OLD?
	#combat.connect("update_information", update_information) ##Old, was in use with the combat log
	controller.connect("target_detailed_info", _target_detailed_info)

#
# Plays the transition animation on combat map begin
#
func transition_in_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.set_label_text(playerOverworldData.current_campaign.name + " - Floor " + str(playerOverworldData.floors_climbed))
	scene_transition.play_animation("level_fade_out")
	await get_tree().create_timer(5).timeout
	scene_transition.queue_free()

#
# transitions out the animation played on combat map begin
#
func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

#
# Creates the unit action container
#
func create_unit_action_container(available_actions:Array[String]):
	var unit_action_container = UnitActionContainer.instantiate()
	unit_action_container.populate(available_actions, controller)
	self.add_child(unit_action_container)
	active_ui_node = unit_action_container
	unit_action_container.grab_focus()

#
# Creates the combat map game menu screen
#
func create_combat_map_game_menu():
	var game_menu = COMBAT_MAP_CAMPAIGN_MENU.instantiate()
	await game_menu
	self.add_child(game_menu)
	game_menu.end_turn_btn.pressed.connect(func():controller.fsm_game_menu_end_turn())
	game_menu.cancel_btn.pressed.connect(func():controller.fsm_game_menu_cancel())
	active_ui_node = game_menu

#
# Frees the current node stored in the "active_ui_node" used in state transitions
#
func destory_active_ui_node():
	if active_ui_node != null:
		active_ui_node.queue_free()

## OLD
func target_selected(info: Dictionary):  ##OLD
	populate_combat_info(info)
	
func populate_combat_info(info: Dictionary): ##OLD
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

func _on_end_turn_button_pressed(): ##OLD
	print("End Turn Button pressed")
	turn_ended.emit()

#
# Creates the attack action inventory used to select the weapon to be used in the combat preview
#
func create_attack_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var attack_action_inventory = ATTACK_ACTION_INVENTORY.instantiate()
	self.add_child(attack_action_inventory)
	await attack_action_inventory
	attack_action_inventory.item_selected.connect(controller.fsm_attack_action_inventory_confirm.bind())
	attack_action_inventory.new_item_hovered.connect(controller.fsm_attack_action_inventory_confirm_new_hover.bind())
	#TO BE CONNECTED CANCEL
	attack_action_inventory.populate(inputCombatUnit, inventory)
	active_ui_node = attack_action_inventory
	attack_action_inventory.grab_focus()

#
# Creates the attack action inventory used to select the weapon to be used in the combat preview
#
func create_support_action_inventory(inputCombatUnit : CombatUnit, inventory: Array[UnitInventorySlotData]):
	var support_action_inventory = SUPPORT_ACTION_INVENTORY.instantiate()
	self.add_child(support_action_inventory)
	await support_action_inventory
	support_action_inventory.item_selected.connect(controller.fsm_attack_action_inventory_confirm.bind())
	support_action_inventory.new_item_hovered.connect(controller.fsm_attack_action_inventory_confirm_new_hover.bind())
	#TO BE CONNECTED CANCEL
	support_action_inventory.populate(inputCombatUnit, inventory)
	active_ui_node = support_action_inventory
	support_action_inventory.grab_focus()



#
#
#
func create_attack_action_combat_exchange_preview(exchange_info: UnitCombatExchangeData, weapon_swap_visable: bool = false):
	var combat_exchange_preview = UNIT_COMBAT_EXCHANGE_PREVIEW.instantiate()
	self.add_child(combat_exchange_preview)
	await combat_exchange_preview
	combat_exchange_preview.set_all(exchange_info,weapon_swap_visable)
	active_ui_node = combat_exchange_preview
	combat_exchange_preview.grab_focus()
	
func update_weapon_attack_action_combat_exchange_preview(exchange_info: UnitCombatExchangeData, weapon_swap_visable: bool = false):
	if active_ui_node is UnitCombatExchangePreview:
		active_ui_node.set_all(exchange_info,weapon_swap_visable)
#
# Populates and displayes the detailed info for a combat unit
#
func _target_detailed_info(combat_unit: CombatUnit):
	if combat_unit:
		if not $UnitStatusDetailed.visible :
			$UnitStatusDetailed.set_unit(combat_unit)
			$UnitStatusDetailed.visible = true
	else :
		$UnitStatusDetailed.visible = false	
	
#
#
#
func _set_tile_info(tile : CombatMapTile, unit:CombatUnit) :
	$combat_tile_info.set_all(tile.terrain, tile.position.x,tile.position.y)
	if(unit):
		$UnitStatus.set_unit(tile.unit)
		$UnitStatus.visible = true
	else:
		$UnitStatus.visible = false


func display_unit_experience_bar(u : Unit):
	$unit_experience_bar.set_reference_unit(u)
	$unit_experience_bar.visible = true

func unit_experience_bar_gain(value: int):
	$unit_experience_bar.update_xp(value)
	await $unit_experience_bar.finished
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")

#
#
#
func hide_unit_experience_bar():
	$unit_experience_bar.visible = false

#
# Calls play_audio with parameters to play the cursor, or move sound in menus
#
func play_cursor():
	play_audio(cursor_sound, ui_map_audio)

#
# Calls play_audio with parameters to play the confirm sound
#
func play_menu_confirm():
	play_audio(menu_confirm_sound, ui_menu_audio)

#
# Calls play_audio with parameters to play the back or cancel sound
#
#
func play_menu_back():
	play_audio(menu_back_sound, ui_menu_audio)

#
# Used to play audio in ui components
#
func play_audio(sound : AudioStream, audio_source: AudioStreamPlayer):
	audio_source.stream = sound
	audio_source.play()
	await audio_source.finished

#
# @Signal 
# emits unit_experience_ended after unit experience bar animation is complete
#
func _on_unit_experience_bar_finished() -> void:
	hide_unit_experience_bar()
	emit_signal("unit_experience_ended")

"""
func set_inventory_list_support(unit: Unit): ## OLD
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

##OLD
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
"""
