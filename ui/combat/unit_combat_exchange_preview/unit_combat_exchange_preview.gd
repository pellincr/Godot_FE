extends Control

var combatExchange: CombatExchange

const up_theme = preload("res://ui/combat/unit_combat_exchange_preview/wpn_triangle_up.tres")
const down_theme = preload("res://ui/combat/unit_combat_exchange_preview/wpn_triangle_down.tres")

const down_arrow_char = "↓"
const up_arrow_char = "↑"

var distance : int
var tween_complete :bool = true
var effectiveness_tween_def_complete :bool = true
var effectiveness_tween_atk_complete :bool = true
var tween_active : bool = false
var tween_target : Label = null

var double_attacker : int
var attacker: CombatUnit
var attacker_hit_chance: int
var attacker_damage : int
var attacker_critical_chance : int 
var attacker_effective: bool = false

var defender : CombatUnit #name, hp, equipped - name, uses,icon
var defender_can_attack : bool
var defender_hit_chance: int
var defender_damage : int
var defender_critical_chance : int 
var defender_effective: bool = false

var wpn_triangle_adv_unit : Unit = null

func _ready():
	combatExchange = CombatExchange.new()
	
func _process(delta):
	if tween_active: 
		if tween_target:
			if tween_complete:
				tween_complete = false 
				tween_label()
	if attacker_effective: 
		if effectiveness_tween_atk_complete:
				effectiveness_tween_atk_complete = false 
				effectiveness_tween_atk()
	if defender_effective: 
		if effectiveness_tween_def_complete:
				effectiveness_tween_def_complete = false 
				effectiveness_tween_atk()
		

func set_all(attacker : CombatUnit, defender : CombatUnit, distance:int):
	self.defender = defender
	self.attacker = attacker
	self.distance = distance
	var combat_exchange_preview = combatExchange.calc_combat_exchange_preview(self.attacker, self.defender,self.distance)
	self.double_attacker = combat_exchange_preview.double_attacker
	self.attacker_hit_chance = combat_exchange_preview.attacker_hit_chance
	self.attacker_damage = combat_exchange_preview.attacker_damage
	self.attacker_critical_chance = combat_exchange_preview.attacker_critical_chance
	self.defender_can_attack = combat_exchange_preview.defender_can_attack
	self.defender_hit_chance = combat_exchange_preview.defender_hit_chance
	self.defender_damage = combat_exchange_preview.defender_damage
	self.defender_critical_chance = combat_exchange_preview.defender_critical_chance
	self.attacker_effective = combat_exchange_preview.attacker_effective
	self.defender_effective = combat_exchange_preview.defender_effective
	self.wpn_triangle_adv_unit = combatExchange.check_weapon_triangle(attacker.unit, defender.unit)
	update_display()


func update_display():
	update_attacker_display()
	update_defender_display()
	update_attacker_combat_values()
	update_defender_combat_values()
	update_double()
	update_weapon_triangle()


func update_weapon_triangle():
	if (wpn_triangle_adv_unit == attacker.unit):
		$wpn_triangle_attack.visible = true
		$wpn_triangle_def.visible = true
		$wpn_triangle_attack.text = up_arrow_char
		$wpn_triangle_attack.theme = up_theme
		$wpn_triangle_def.text = down_arrow_char
		$wpn_triangle_def.theme = down_theme
	elif(wpn_triangle_adv_unit == defender.unit):
		$wpn_triangle_attack.visible = true
		$wpn_triangle_def.visible = true
		$wpn_triangle_attack.text = down_arrow_char
		$wpn_triangle_attack.theme = down_theme
		$wpn_triangle_def.text = up_arrow_char
		$wpn_triangle_def.theme = up_theme
	else : 
		$wpn_triangle_attack.visible = false
		$wpn_triangle_def.visible = false
	
func update_attacker_display():
	$CenterContainer/HBoxContainer/AttackerInfo/Name.text = attacker.unit.name
	$CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Icon.texture = attacker.unit.inventory.equipped.icon
	$CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Name.text = attacker.unit.inventory.equipped.name
	$CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Uses.text = str(attacker.unit.inventory.equipped.uses)
	
func update_defender_display():
	$CenterContainer/HBoxContainer/DefenderInfo/Name.text = defender.unit.name
	if defender.unit.inventory.equipped:
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Icon.texture = defender.unit.inventory.equipped.icon
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Name.text = defender.unit.inventory.equipped.name
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Uses.text = str(defender.unit.inventory.equipped.uses)
	else: 
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Icon.texture = null
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Name.text = "--"
		$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Uses.text = "--"

func update_attacker_combat_values():
	$CenterContainer/HBoxContainer/CombatStats/AttackerStats/HP.text = str(attacker.unit.hp)
	$CenterContainer/HBoxContainer/CombatStats/AttackerStats/Damage.text = str(attacker_damage)
	$CenterContainer/HBoxContainer/CombatStats/AttackerStats/Hit.text = str(attacker_hit_chance)
	$CenterContainer/HBoxContainer/CombatStats/AttackerStats/Crit.text = str(attacker_critical_chance)
	
	
func update_defender_combat_values():
	$CenterContainer/HBoxContainer/CombatStats/DefenderStats/HP.text = str(defender.unit.hp)
	if defender_can_attack: 
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Damage.text = str(defender_damage)
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Hit.text = str(defender_hit_chance)
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Crit.text = str(defender_critical_chance)
	else : 
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Damage.text = "--"
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Hit.text = "--"
		$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Crit.text = "--"

func update_double():
	if double_attacker == 1:
		$double_atk.visible = true
		tween_active = true
		tween_target = $double_atk
		$double_def.visible = false
	elif double_attacker == 2 and defender_can_attack:
		$double_atk.visible = false
		$double_def.visible = true
		tween_active = true
		tween_target = $double_def
	else:
		tween_active = false
		$double_atk.visible = false
		$double_def.visible = false


func tween_label():
	var tween = get_tree().create_tween()
	tween.tween_property(
	tween_target, "scale", Vector2(.75,.75), .35
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
	tween_target, "scale", Vector2(1,1), .35
	).set_delay(.2)
	await tween.finished
	tween_complete = true



func effectiveness_tween_atk():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Icon, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/CombatStats/AttackerStats/Damage, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Name, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Icon, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/CombatStats/AttackerStats/Damage, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/AttackerInfo/ItemInfo/Name, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	await tween.finished
	effectiveness_tween_atk_complete = true

func effectiveness_tween_def():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Icon, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/CombatStats/DefenderStats/Damage, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(
	$CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Name, "modulate", Color.GREEN, .5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Icon, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/CombatStats/DefenderStats/Damage, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	tween.parallel().tween_property($CenterContainer/HBoxContainer/DefenderInfo/ItemInfo/Name, "modulate", Color.WHITE, .5).set_trans(Tween.TRANS_SINE).set_delay(.5)
	await tween.finished
	effectiveness_tween_atk_complete = true
