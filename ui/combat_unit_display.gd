extends Control
class_name UnitMapDisplay

var max_hp: int
var hp: int
var is_boss : bool
var is_effective : bool
var unit_sprite: Texture2D
var reference_unit : Unit
	
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

func set_reference_unit(unit: Unit) :
	self.reference_unit = unit
	update_values()
	
func update_values():
	set_hp(self.reference_unit.hp)
	set_max_hp(self.reference_unit.max_hp)
	set_unit_sprite(self.reference_unit.map_sprite)

static func create(position:Vector2, boss: bool = false, danger: bool = false) -> UnitMapDisplay:
	var unit_display = UnitMapDisplay.new()
	unit_display.global_position = position * Vector2(32, 32)
	return unit_display
	
