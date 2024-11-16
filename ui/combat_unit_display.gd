extends Control
class_name CombatUnitDisplay

var max_hp: int
var hp: int
var is_boss : bool
var is_effective : bool
var unit_sprite: Texture2D
var reference_unit : CombatUnit
var allegience : int = -1
var turn_taken: bool = false

const RED = Color('#ff8675')
const BLUE = Color('87c8ff')
@onready var shader_material = material as ShaderMaterial
	
func set_max_hp(value: int) : 
	$Healthbar.max_value = value
	self.max_hp = value

func set_hp(value: int) :
	$Healthbar.value = value
	self.hp = value
	
func set_unit_sprite(texture: Texture2D) :
	unit_sprite = texture;
	$UnitSprite.texture = unit_sprite

	
func update_boss_icon():
	$BossIndicator.visible = is_boss
	
func update_warning_icon():
	$WarningIndicator.visible = is_effective

func set_reference_unit(unit: CombatUnit) :
	self.reference_unit = unit
	set_values()

func set_values():
	if not shader_material:
		await self.ready
	set_max_hp(self.reference_unit.unit.max_hp)
	set_hp(self.reference_unit.unit.hp)
	set_unit_sprite(self.reference_unit.unit.map_sprite)
	set_allegience(self.reference_unit.allegience)
	set_color_factor(self.reference_unit.turn_taken)
	
	
func update_values():
	set_max_hp(self.reference_unit.unit.max_hp)
	set_hp(self.reference_unit.unit.hp)
	set_unit_sprite(self.reference_unit.unit.map_sprite)
	set_allegience(self.reference_unit.allegience)
	set_color_factor(self.reference_unit.turn_taken)
	
func set_allegience(team : int):
	self.allegience = team
	if allegience == 0:
		$UnitSprite.material.set_shader_parameter("modulate_color",BLUE)
	elif allegience == 1:
		$UnitSprite.material.set_shader_parameter("modulate_color", RED)
	else :
		$UnitSprite.material.set_shader_parameter("modulate_color",Color.WHITE)

func set_color_factor(turn_taken: bool):
	self.turn_taken = turn_taken
	if turn_taken:
		$UnitSprite.material.set_shader_parameter("color_factor", 1)
		$UnitSprite.material.set_shader_parameter("line_color", Color.BLACK)
	else :
		$UnitSprite.material.set_shader_parameter("color_factor", 0)
		$UnitSprite.material.set_shader_parameter("line_color", Color.WHITE)


static func create() -> CombatUnitDisplay:
	var unit_display = CombatUnitDisplay.new()
	##unit_display.global_position = position * Vector2(32, 32)
	return unit_display
