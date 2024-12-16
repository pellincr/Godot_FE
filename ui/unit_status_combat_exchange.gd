extends Control

class_name UnitStatusCombatExchange

var attacking_unit : Unit
var a_hit : int
var a_dmg: int
var a_crit: int
var defending_unit : Unit
var d_hit : int
var d_dmg: int
var d_crit: int

func set_all(a_unit, a_hit, a_dmg, a_crit, d_unit, d_hit, d_dmg, d_crit):
	set_attacking_unit(a_unit)
	set_attacking_combat_var(a_hit, a_dmg, a_crit)
	set_defending_unit(d_unit)
	set_defending_combat_var(d_hit, d_dmg, d_crit)
	update_fields()

func set_attacking_combat_var(hit:int, dmg:int, crit:int):
	self.a_hit = hit
	self.a_dmg = dmg
	self.a_crit = crit

func set_defending_combat_var(hit:int, dmg:int, crit:int):
	self.d_hit = hit
	self.d_dmg = dmg
	self.d_crit = crit

func set_defending_unit(input_unit:Unit):
	self.defending_unit = input_unit
	
func set_attacking_unit(input_unit:Unit):
	self.attacking_unit = input_unit

func set_units(a_unit: Unit, d_unit:Unit) : 
	set_attacking_unit(a_unit)
	set_defending_unit(d_unit)

func set_attacking_unit_icon(value: Texture2D) : 
	$Background/AttackingUnit/UnitIcon.texture = value
	
func set_defending_unit_icon(value: Texture2D) : 
	$Background/DefendingUnit/UnitIcon.texture = value

func set_unit_name(value: String) : 
	$UnitName.text = value
	
func set_attacking_unit_health_bar_values(maximum: int, current:int) : 
	$Background/AttackingUnit/HealthBar/Bar.max_value = maximum
	$Background/AttackingUnit/HealthBar/Bar.value = current
	$Background/AttackingUnit/HealthBar/Value.text = str(current)
	
func set_defending_unit_health_bar_values(maximum: int, current:int) : 
	$Background/DefendingUnit/HealthBar/Bar.max_value = maximum
	$Background/DefendingUnit/HealthBar/Bar.value = current
	$Background/DefendingUnit/HealthBar/Value.text = str(current)

func set_attacking_grid(attack: int, hit:int, crit:int, attack_speed:int): 	
	set_attacking_attack_value(attack)
	set_attacking_hit_value(hit)
	set_attacking_critical_value(crit)
	set_attacking_attack_speed_value(attack_speed)

func set_attacking_attack_value(value: int): 
	$Background/AttackingUnit/StatsGrid/AttackValue.text = str(value)

func set_attacking_hit_value(value: int): 
	$Background/AttackingUnit/StatsGrid/HitValue.text = str(value)
	
func set_attacking_attack_speed_value(value: int): 
	$Background/AttackingUnit/StatsGrid/AttackSpeedValue.text = str(value)

func set_attacking_critical_value(value: int): 
	$Background/AttackingUnit/StatsGrid/CriticalValue.text = str(value)
	
func set_attacking_update_unit_name(value: String): 
	$Background/AttackingUnit/UnitName.text = value
	
func set_defending_grid(attack: int, hit:int, crit:int, attack_speed:int): 	
	set_defending_attack_value(attack)
	set_defending_hit_value(hit)
	set_defending_critical_value(crit)
	set_defending_attack_speed_value(attack_speed)

func set_defending_attack_value(value: int): 
	$Background/DefendingUnit/StatsGrid/AttackValue.text = str(value)

func set_defending_hit_value(value: int): 
	$Background/DefendingUnit/StatsGrid/HitValue.text = str(value)
	
func set_defending_attack_speed_value(value: int): 
	$Background/DefendingUnit/StatsGrid/AttackSpeedValue.text = str(value)

func set_defending_critical_value(value: int): 
	$Background/DefendingUnit/StatsGrid/CriticalValue.text = str(value)
	
func set_defending_update_unit_name(value: String): 
	$Background/DefendingUnit/UnitName.text = value

func set_attacking_fields():
	set_attacking_update_unit_name(attacking_unit.unit_name)
	set_attacking_unit_icon(attacking_unit.icon)
	set_attacking_unit_health_bar_values(attacking_unit.max_hp, attacking_unit.hp)
	set_attacking_grid(a_dmg,a_hit, a_crit, attacking_unit.attack_speed)

func set_defending_fields():
	set_defending_update_unit_name(defending_unit.unit_name)
	set_defending_unit_icon(defending_unit.icon)
	set_defending_unit_health_bar_values(defending_unit.max_hp, defending_unit.hp)
	set_defending_grid(d_dmg, d_hit, d_crit, defending_unit.attack_speed)
	
func update_fields():
	set_attacking_fields()
	set_defending_fields()
