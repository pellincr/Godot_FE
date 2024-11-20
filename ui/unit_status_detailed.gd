extends Control

class_name UnitStatusDetailedUI

var unit : Unit

func set_unit(input_unit:Unit):
	self.unit = input_unit
	update_fields()

func set_unit_icon(value: Texture2D) : 
	$LeftPanel/UnitSprite.texture = value

func set_unit_name(value: String) : 
	$LeftPanel/UnitName.text = value
	
func set_unit_sub_header(level: int, unit_type: String) : 
	#Level 15 Classname
	$LeftPanel/UnitSubHeader.text = "Level " + str(level) + " " + unit_type
	
func set_unit_health_bar_values(max: int, current:int) : 
	$LeftPanel/HealthBar/Bar.max_value = max
	$LeftPanel/HealthBar/Bar.value = current
	$LeftPanel/HealthBar/Value.text = convert_int_to_bar_format(max, current)

func set_unit_xp_bar_values(max: int, current:int) : 
	$LeftPanel/ExperienceBar/Bar.max_value = max
	$LeftPanel/ExperienceBar/Bar.value = current
	$LeftPanel/ExperienceBar/Value.text = convert_int_to_bar_format(max, current)

func convert_int_to_bar_format(max:int, current: int) -> String:
	return str(current) + " / " + str(max) 

func update_stats_grid(attack: int, hit:int, attack_speed:int, avoid:int): 	
	update_attack_value(attack)
	update_hit_value(hit)
	update_attack_speed_value(attack_speed)
	update_avoid_value(avoid)
	
func update_attack_value(value: int): 
	$LeftPanel/StatsGrid/AttackValue.text = str(value)

func update_hit_value(value: int): 
	$LeftPanel/StatsGrid/HitValue.text = str(value)
	
func update_attack_speed_value(value: int): 
	$LeftPanel/StatsGrid/AttackSpeedValue.text = str(value)

func update_avoid_value(value: int): 
	$LeftPanel/StatsGrid/AvoidValue.text = str(value)
	
func update_unit_name(value: String): 
	$LeftPanel/UnitName.text = value
	
func update_unit_stats():
	update_strength_stat(unit.strength, unit.strength_cap)
	update_magic_stat(unit.magic, unit.magic_cap)
	update_skill_stat(unit.skill, unit.skill_cap)
	update_speed_stat(unit.speed, unit.speed_cap)
	update_luck_stat(unit.luck, unit.luck_cap)
	update_defense_stat(unit.defense, unit.defense_cap)
	update_m_defense_stat(unit.magic_defense, unit.magic_defense_cap)

func update_strength_stat(current: int, max:int):
	$RightPanel/StatsGrid/StrengthContainer/Value.text = str(current)
	$RightPanel/StatsGrid/StrengthContainer/Bar.max_value = max
	$RightPanel/StatsGrid/StrengthContainer/Bar.value = current

func update_magic_stat(current: int, max:int):
	$RightPanel/StatsGrid/MagicContainer/Value.text = str(current)
	$RightPanel/StatsGrid/MagicContainer/Bar.max_value = max
	$RightPanel/StatsGrid/MagicContainer/Bar.value = current

func update_skill_stat(current: int, max:int):
	$RightPanel/StatsGrid/SkillContainer/Value.text = str(current)
	$RightPanel/StatsGrid/SkillContainer/Bar.max_value = max
	$RightPanel/StatsGrid/SkillContainer/Bar.value = current

func update_speed_stat(current: int, max:int):
	$RightPanel/StatsGrid/SpeedContainer/Value.text = str(current)
	$RightPanel/StatsGrid/SpeedContainer/Bar.max_value = max
	$RightPanel/StatsGrid/SpeedContainer/Bar.value = current

func update_luck_stat(current: int, max:int):
	$RightPanel/StatsGrid/LuckContainer/Value.text = str(current)
	$RightPanel/StatsGrid/LuckContainer/Bar.max_value = max
	$RightPanel/StatsGrid/LuckContainer/Bar.value = current

func update_defense_stat(current: int, max:int):
	$RightPanel/StatsGrid/DefenseContainer/Value.text = str(current)
	$RightPanel/StatsGrid/DefenseContainer/Bar.max_value = max
	$RightPanel/StatsGrid/DefenseContainer/Bar.value = current

func update_m_defense_stat(current: int, max:int):
	$RightPanel/StatsGrid/MagicDefenseContainer/Value.text = str(current)
	$RightPanel/StatsGrid/MagicDefenseContainer/Bar.max_value = max
	$RightPanel/StatsGrid/MagicDefenseContainer/Bar.value = current


func set_slot_info(item: ItemDefinition):
	$RightPanel/Inventory/Slot1Container/Equipped.visible = true
	if item :
		$RightPanel/Inventory/Slot1Container/HBoxContainer/icon.texture = item.icon
		$RightPanel/Inventory/Slot1Container/HBoxContainer/Name.text = item.name
		$RightPanel/Inventory/Slot1Container/HBoxContainer/Uses.text = str(item.uses)
	else :
		$RightPanel/Inventory/Slot1Container/HBoxContainer/icon.texture = null
		$RightPanel/Inventory/Slot1Container/HBoxContainer/Name.text = ""
		$RightPanel/Inventory/Slot1Container/HBoxContainer/Uses.text = ""
	
func set_inventory_slot_2(item: ItemDefinition):
	$RightPanel/Inventory/Slot2Container/Equipped.visible = false
	if item :
		$RightPanel/Inventory/Slot2Container/HBoxContainer/icon.texture = item.icon
		$RightPanel/Inventory/Slot2Container/HBoxContainer/Name.text = item.name
		$RightPanel/Inventory/Slot2Container/HBoxContainer/Uses.text = str(item.uses)
	else :
		$RightPanel/Inventory/Slot2Container/HBoxContainer/icon.texture = null
		$RightPanel/Inventory/Slot2Container/HBoxContainer/Name.text = ""
		$RightPanel/Inventory/Slot2Container/HBoxContainer/Uses.text = ""

func set_inventory_slot_3(item: ItemDefinition):
	$RightPanel/Inventory/Slot3Container/Equipped.visible = false
	if item :
		$RightPanel/Inventory/Slot3Container/HBoxContainer/icon.texture = item.icon
		$RightPanel/Inventory/Slot3Container/HBoxContainer/Name.text = item.name
		$RightPanel/Inventory/Slot3Container/HBoxContainer/Uses.text = str(item.uses)
	else :
		$RightPanel/Inventory/Slot3Container/HBoxContainer/icon.texture = null
		$RightPanel/Inventory/Slot3Container/HBoxContainer/Name.text = ""
		$RightPanel/Inventory/Slot3Container/HBoxContainer/Uses.text = ""

func set_inventory_slot_4(item: ItemDefinition):
	$RightPanel/Inventory/Slot4Container/Equipped.visible = false
	if item :
		$RightPanel/Inventory/Slot4Container/HBoxContainer/icon.texture = item.icon
		$RightPanel/Inventory/Slot4Container/HBoxContainer/Name.text = item.name
		$RightPanel/Inventory/Slot4Container/HBoxContainer/Uses.text = str(item.uses)
	else :
		$RightPanel/Inventory/Slot4Container/HBoxContainer/icon.texture = null
		$RightPanel/Inventory/Slot4Container/HBoxContainer/Name.text = ""
		$RightPanel/Inventory/Slot4Container/HBoxContainer/Uses.text = ""

func set_inventory() : 
	var inventory_slots = $RightPanel/Inventory.get_children()
	for i in range(inventory_slots.size()):
		print (str(i))
		var slot = inventory_slots[i]
		if(i < unit.inventory.items.size()):
			if unit.inventory.items.size() > i:
				var item = unit.inventory.items[i]
				if i == 0: 
					slot.get_child(0).visible = true
				else : 
					slot.get_child(0).visible = false
				var slot_box = slot.get_child(1)
				slot_box.get_child(0).texture = item.icon
				slot_box.get_child(1).text = item.name
				slot_box.get_child(2).text = str(item.uses)
		else : 
			slot.get_child(0).visible = false
			var slot_box = slot.get_child(1)
			slot_box.get_child(0).texture = null
			slot_box.get_child(1).text = ''
			slot_box.get_child(2).text = ''

func update_fields():
	update_unit_name(unit.unit_name)
	set_unit_icon(unit.map_sprite)
	set_unit_health_bar_values(unit.max_hp, unit.hp)
	set_unit_xp_bar_values(100, unit.experience)
	set_unit_sub_header(unit.level, UnitTypeDatabase.unit_types[unit.unit_class_key].unit_type_name)
	update_stats_grid(unit.attack, unit.hit,unit.attack_speed, unit.avoid)
	update_unit_stats()
	set_inventory()
	
