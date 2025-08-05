extends Control

class_name UnitStatusDetailedUI

var Cunit : CombatUnit
var stats_grid_bar_max_bar_length = 150

func _ready():
	stats_grid_bar_max_bar_length = $RightPanel/StatsGrid/StrengthContainer.size.x

func set_unit(input_unit:CombatUnit):
	self.Cunit = input_unit
	update_fields()

func set_unit_icon(value: Texture2D) : 
	$LeftPanel/UnitSprite.texture = value

func set_unit_name(value: String) : 
	$LeftPanel/UnitName.text = value
	
func set_unit_sub_header(level: int, unit_type: String) : 
	#Level 15 Classname
	$LeftPanel/UnitSubHeader.text = "Level " + str(level) + " " + unit_type
	
func set_unit_health_bar_values(maximum: int, current:int) : 
	$LeftPanel/HealthBar/Bar.max_value = maximum
	$LeftPanel/HealthBar/Bar.value = current
	$LeftPanel/HealthBar/Value.text = convert_int_to_bar_format(maximum, current)

func set_unit_xp_bar_values(maximum: int, current:int) : 
	$LeftPanel/ExperienceBar/Bar.max_value = maximum
	$LeftPanel/ExperienceBar/Bar.value = current
	$LeftPanel/ExperienceBar/Value.text = convert_int_to_bar_format(maximum, current)

func convert_int_to_bar_format(maximum:int, current: int) -> String:
	return str(current) + " / " + str(maximum) 

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
	update_strength_stat(Cunit.unit.stats.strength, Cunit.unit.get_unit_type_definition().maxuimum_stats.strength)
	update_magic_stat(Cunit.unit.stats.magic, Cunit.unit.get_unit_type_definition().maxuimum_stats.magic)
	update_skill_stat(Cunit.unit.stats.skill, Cunit.unit.get_unit_type_definition().maxuimum_stats.skill)
	update_speed_stat(Cunit.unit.stats.speed, Cunit.unit.get_unit_type_definition().maxuimum_stats.speed)
	update_luck_stat(Cunit.unit.stats.luck, Cunit.unit.get_unit_type_definition().maxuimum_stats.luck)
	update_defense_stat(Cunit.unit.stats.defense, Cunit.unit.get_unit_type_definition().maxuimum_stats.defense)
	update_m_defense_stat(Cunit.unit.stats.resistance, Cunit.unit.get_unit_type_definition().maxuimum_stats.resistance)

func update_strength_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/StrengthContainer)
	#$RightPanel/StatsGrid/StrengthContainer/Value.text = str(current)
	#$RightPanel/StatsGrid/StrengthContainer/Bar.max_value = max
	#$RightPanel/StatsGrid/StrengthContainer/Bar.value = current
	#set_stat_bar_size(max,$RightPanel/StatsGrid/StrengthContainer/Bar)
	#

func update_magic_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/MagicContainer)

func update_skill_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/SkillContainer)
	
func update_speed_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/SpeedContainer)	


func update_luck_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/LuckContainer)	
	
func update_defense_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/DefenseContainer)		

func update_m_defense_stat(current: int, maximum:int):
	update_target_stat(current, maximum, $RightPanel/StatsGrid/MagicDefenseContainer)	


func update_target_stat(current:int, maximum:int, ui_target:PanelContainer):
	var ui_elements = ui_target.get_children()
	if(current == maximum ):
		ui_elements[1].add_theme_color_override("font_color", Color.GREEN)
	else : 
		ui_elements[1].add_theme_color_override("font_color", Color.WHITE)
	ui_elements[1].text = str(current)
	ui_elements[0].max_value = maximum
	ui_elements[0].value = current
	set_stat_bar_size(maximum,ui_elements[0])
	

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
		var slot = inventory_slots[i]
		if(i < Cunit.unit.inventory.items.size()):
			if Cunit.unit.inventory.items.size() > i:
				var item = Cunit.unit.inventory.items[i]
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
	update_unit_name(Cunit.unit.name)
	set_unit_icon(Cunit.unit.map_sprite)
	set_unit_health_bar_values(Cunit.unit.stats.hp, Cunit.unit.hp)
	set_unit_xp_bar_values(100, Cunit.unit.experience)
	set_unit_sub_header(Cunit.unit.level, UnitTypeDatabase.get_definition(Cunit.unit.unit_type_key).unit_type_name)
	update_stats_grid(Cunit.unit.attack, Cunit.unit.hit,Cunit.unit.attack_speed, Cunit.calc_map_avoid())
	update_unit_stats()
	set_inventory()

func set_stat_bar_size(cap:int, target : ProgressBar):
	var max_stat = 30
	var size_ratio : float = float(cap)/float(max_stat)
	target.custom_minimum_size = Vector2(int(size_ratio * stats_grid_bar_max_bar_length),0)
	##get the length
	
	
	
