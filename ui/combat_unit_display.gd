extends Control
class_name CombatUnitDisplay

var max_hp: int
var hp: int
var is_boss : bool
var is_effective : bool
var unit_sprite: Texture2D
var reference_unit : CombatUnit
var allegience : int

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
	update_values()

func update_values():
	set_max_hp(self.reference_unit.unit.max_hp)
	set_hp(self.reference_unit.unit.hp)
	set_unit_sprite(self.reference_unit.unit.map_sprite)
	

func set_outline_color():
	if not shader_material:
		await self.ready
	else :
		if(reference_unit.allegience == 0) : 
			shader_material.set_shader_parameter("shader_parameter/color", Color.BLUE)
		elif(reference_unit.allegience == 1) :
			shader_material.set_shader_parameter("shader_parameter/color", Color.DARK_RED)
		elif(reference_unit.allegience == 2) :
			shader_material.set_shader_parameter("shader_parameter/color", Color.DARK_GREEN)
		else: 
			pass
	return

static func create() -> CombatUnitDisplay:
	var unit_display = CombatUnitDisplay.new()
	##unit_display.global_position = position * Vector2(32, 32)
	return unit_display
