extends Control
class_name InventoryItemIcon

@export var hovered : bool
@export var pressed : bool 
@export var disabled : bool
@export var equipped : bool

@export var item_sprite : Texture2D

@onready var item_icon: TextureRect = $ItemIcon
@onready var equipped_label: Label = $EquippedLabel

func _ready():
	self.update_display()

func set_image(texture: Texture2D):
	self.item_sprite = texture
	self.update_display()

func update_display():
	if self.item_sprite != null:
		item_icon.texture = item_sprite
	else:
		item_icon.texture = null

func clear_item():
	self.item_sprite = null
	self.update_display()

func set_equipped(state : bool):
	self.equipped = state
	equipped_label.visible = self.equipped

func set_disabled(state: bool):
	pass

func set_item(item: ItemDefinition):
	self.item_sprite = item.icon
	self.update_display()
