extends PanelContainer
class_name LevelUpAttributeContainer
@export var attribute_name : String
@export var attribute_value : int
@export var level_up_bonus : int


func set_all(name:String, value:int, lvl_bonus:int):
	self.attribute_name = name
	self.attribute_value = value
	self.level_up_bonus = lvl_bonus

func set_ints(value:int, lvl_bonus:int):
	self.attribute_value = value
	self.level_up_bonus = lvl_bonus

func _ready():
	pass
	#update_fields()


func update_fields():
	update_attribute_name()
	update_attribute_value()
	update_level_up_bonus()

func update_attribute_name():
	$HSplitContainer/MarginContainer2/AttributeLabel.text = self.attribute_name

func update_attribute_value():
	$HSplitContainer/MarginContainer/HSplitContainer/Value.text = str(self.attribute_value)

func update_level_up_bonus():
	if (level_up_bonus > 0): 
		$HSplitContainer/MarginContainer/HSplitContainer/LevelValue.text = "+ " + str(self.level_up_bonus)
	else : 
		$HSplitContainer/MarginContainer/HSplitContainer/LevelValue.text = ""
