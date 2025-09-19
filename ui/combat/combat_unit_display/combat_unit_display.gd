extends Control
class_name CombatUnitDisplay

signal update_complete

var max_hp: int
var hp: int
var is_boss : bool
var drops_item : bool
var is_effective : bool
var unit_sprite: Texture2D
var reference_unit : CombatUnit
var allegience : int = -1
var turn_taken: bool = false

var healthbar_update_complete: bool = false

const RED = Color('#ff8675')
const BLUE = Color('87c8ff')
@onready var shader_material = material as ShaderMaterial
	
func _ready() -> void:
	$Healthbar.connect("finished", healthbar_update_completed)

func set_max_hp(value: int) : 
	$Healthbar.max_value = value
	self.max_hp = value

func set_hp(value: int) :
	$Healthbar.value = value
	self.hp = value

func update_hp(value: int) :
	$Healthbar.desired_value = value
	await $Healthbar.activate_tween()
	self.hp = value

func set_unit_sprite(texture: Texture2D) :
	unit_sprite = texture;
	$UnitSprite.texture = unit_sprite

	
func update_boss_icon():
	$BossIndicator.visible = is_boss
	
func update_warning_icon():
	$WarningIndicator.visible = is_effective

func update_drop_indicator():
	$drop_indicator.visible = drops_item

func set_reference_unit(unit: CombatUnit) :
	self.reference_unit = unit
	set_values()

func set_values():
	if not shader_material:
		await self.ready
	set_max_hp(self.reference_unit.get_max_hp())
	set_hp(self.reference_unit.current_hp)
	set_unit_sprite(self.reference_unit.unit.map_sprite)
	set_allegience(self.reference_unit.allegience)
	set_color_factor(self.reference_unit.turn_taken)
	set_is_boss(self.reference_unit.is_boss)
	set_drops_item(self.reference_unit.drops_item)
	
	
func update_values():
	healthbar_update_complete = false
	set_max_hp(self.reference_unit.get_max_hp())
	await update_hp(self.reference_unit.current_hp)
	set_unit_sprite(self.reference_unit.unit.map_sprite)
	set_allegience(self.reference_unit.allegience)
	set_color_factor(self.reference_unit.turn_taken)
	set_is_boss(self.reference_unit.is_boss)
	set_drops_item(self.reference_unit.drops_item)
	
func set_allegience(team : int):
	self.allegience = team
	if allegience == 0:
		$UnitSprite.material.set_shader_parameter("line_color", Color.NAVY_BLUE)
		#$UnitSprite.material.set_shader_parameter("modulate_color",BLUE)
	elif allegience == 1:
		$UnitSprite.material.set_shader_parameter("line_color", Color.DARK_RED)
		#$UnitSprite.material.set_shader_parameter("modulate_color", RED)
	else :
		$UnitSprite.material.set_shader_parameter("line_color", Color.WHITE)
		#$UnitSprite.material.set_shader_parameter("modulate_color",Color.WHITE)

func set_color_factor(turn_taken: bool):
	self.turn_taken = turn_taken
	if turn_taken:
		$UnitSprite.material.set_shader_parameter("color_factor", 1)
		#$UnitSprite.material.set_shader_parameter("line_color", Color.BLACK)
	else :
		$UnitSprite.material.set_shader_parameter("color_factor", 0)
		#$UnitSprite.material.set_shader_parameter("line_color", Color.WHITE)

func set_is_boss(state: bool):
	self.is_boss = state
	$boss_indicator.visible = is_boss

func set_drops_item(state: bool):
	self.drops_item = state
	$drop_indicator.visible = drops_item

func healthbar_update_completed():
	healthbar_update_complete = true
	emit_signal("update_complete")

static func create() -> CombatUnitDisplay:
	var unit_display = CombatUnitDisplay.new()
	##unit_display.global_position = position * Vector2(32, 32)
	return unit_display

func set_healthbar_visability(visibility : bool):
	$Healthbar.visible = visibility
