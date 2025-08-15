extends Resource

class_name CombatUnit

enum Group
{
	PLAYERS,
	ENEMIES,
	FRIENDLY,
	NOMAD
}

# Status
var alive : bool
var allegience : Constants.FACTION
var ai_type: Constants.UNIT_AI_TYPE
var is_boss: bool = false
#var drops_last_item : bool = false

# Action Economy
var turn_taken : bool = false
var major_action_taken : bool = false
var minor_action_taken: bool = false
var action_list :  Array[String] #is this redundant?

var effective_move : int = 0

var unit : Unit

# The effective Stats of a unit
var stats : combatMapUnitStat

var map_position : Vector2i
var map_terrain : Terrain

var move_position: Vector2i
var move_terrain : Terrain

var map_display : CombatUnitDisplay



static func create(unit: Unit, team: int, ai:int = 0, boss:bool = false) -> CombatUnit:
	var instance = CombatUnit.new()
	instance.alive = true
	instance.turn_taken = false
	instance.unit = unit
	instance.ai_type = ai
	instance.allegience = team
	instance.effective_move = unit.stats.movement
	instance.is_boss = boss
	return instance

func set_map_terrain(ter : Terrain) :
	map_terrain = ter
	 
func calc_map_avoid()-> int:
	if map_position != move_position:
		if move_terrain:
			return unit.avoid + move_terrain.avoid
	else: 
		if map_terrain:
			return unit.avoid + map_terrain.avoid
	return unit.avoid

func calc_map_avoid_staff() -> int:
	#if current_map_tile:
		#return int(unit.magic_defense * 1.5) + int(unit.luck * .5) + current_map_tile.avoid
	#else: 
		return (unit.magic_defense * 1.5) + int(unit.luck * .5)

func refresh_unit():
	self.minor_action_taken = false
	self.major_action_taken = false
	self.turn_taken = false
	refresh_move()

func refresh_move():
	if unit:
		if unit.stats.movement:
			self.effective_move =  unit.stats.movement

func update_move_tile(cmt: CombatMapTile):
	move_position = cmt.position
	move_terrain = cmt.terrain
	
func update_map_tile(cmt: CombatMapTile):
	map_position = cmt.position
	map_terrain = cmt.terrain

func populate_base_stats():
	# Add stats from Unit
	stats.max_hp.append(StatModifier.create(unit.stats.hp, "Unit"))
	stats.strength.append(StatModifier.create(unit.stats.strength, "Unit"))
	
	stats.magic.append(StatModifier.create(unit.stats.magic, "Unit"))
	stats.skill.append(StatModifier.create(unit.stats.skill, "Unit"))
	stats.speed.append(StatModifier.create(unit.stats.speed, "Unit"))
	stats.luck.append(StatModifier.create(unit.stats.luck, "Unit"))
	stats.defense.append(StatModifier.create(unit.stats.defense, "Unit"))
	stats.resistance.append(StatModifier.create(unit.stats.resistance, "Unit"))

	stats.movement.append(StatModifier.create(unit.stats.movement, "Unit"))
	stats.constitution.append(StatModifier.create(unit.stats.constitution, "Unit"))

	stats.damage.append(StatModifier.create(unit.stats.strength, "Unit"))
	stats.hit.append(StatModifier.create(unit.stats.strength, "Unit"))
	stats.avoid.append(StatModifier.create(unit.stats.strength, "Unit"))
	stats.attack_speed.append(StatModifier.create(unit.stats.strength, "Unit"))
	stats.critical_chance.append(StatModifier.create(unit.stats.strength, "Unit"))
	
	stats.critical_multiplier.append(StatModifier.create(unit.stats.strength, "Unit"))

func populate_attack_speed() -> int:
	var attack_speed : int = 0
	if weapon:
		attack_speed =  clampi(stats.speed.evaluate() - clampi(weapon.weight - stats.constitution.evaluate(), 0, weapon.weight),0, stats.speed.evaluate())
	else : 
		if unit.inventory.get_equipped_weapon():
			attack_speed = clampi(stats.speed.evaluate() - clampi(unit.inventory.get_equipped_weapon().weight.evaluate() - stats.constitution.evaluate(),0, unit.inventory.get_equipped_weapon().weight),0, stats.speed.evaluate())
		else : 
			attack_speed = stats.speed.evaluate()
	return attack_speed
	
func populate_hit() -> int:
	var hit_value : int = 0
		hit_value = clampi(weapon.hit + (2 * stats.skill.evaluate()) + (stats.luck.evaluate()/2), 0, 500)
	else :
		if unit.inventory.get_equipped_weapon():
			hit_value = clampi(unit.inventory.get_equipped_weapon().hit + (2 * stats.skill.evaluate()) + (stats.luck.evaluate()/2), 0, 500)
	return hit_value
	
func populate_critical_hit() -> int:
	var critcal_value : int = 0
	if weapon:
		critcal_value = clampi(weapon.critical_chance + (stats.skill.evaluate()/2), 0 , 100)
	else :
		if unit.inventory.get_equipped_weapon():
			critcal_value = clampi(unit.inventory.get_equipped_weapon().critical_chance + (stats.skill.evaluate()/2), 0 , 100) 
	return critcal_value

func populate_avoid() -> int:
	var avoid_value: int = 0
	if weapon:
		avoid_value = (2 * calculate_attack_speed(weapon)) + stats.luck.evaluate()
	else :
		avoid_value = (2 * calculate_attack_speed()) + stats.luck.evaluate()
	if move_terrain:
		avoid_value += move_terrain.avoid
	return avoid_value

func populate_attack() -> int: 
	var attack_value : int = 0
	var selected_weapon : WeaponDefinition = weapon
	if weapon == null : 
		selected_weapon = unit.inventory.get_equipped_weapon()
	match selected_weapon.item_scaling_type:
		itemConstants.SCALING_TYPE.STRENGTH:
		
	if(selected_weapon.item_scaling_type == itemConstants.SCALING_TYPE.STRENGTH:
		attack_value = stats.strength  + unit.inventory.get_equipped_weapon().damage
	else :
		attack_value = stats.magic.evaluate()   + unit.inventory.get_equipped_weapon().damage
	return attack_value
	
