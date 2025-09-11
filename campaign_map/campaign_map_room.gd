extends Control

class_name CampaignMapRoom

signal selected(room:CampaignRoom)

const ICONS:={
	#Stores the Icon and the Scale it should be placed with
	CampaignRoom.TYPE.NOT_ASSIGNED : [null,Vector2.ONE],
	CampaignRoom.TYPE.BATTLE : [preload("res://resources/sprites/icons/campaign_map_icons/icon_target_2.png"), Vector2.ONE],
	CampaignRoom.TYPE.KEY_BATTLE : [preload("res://resources/sprites/icons/campaign_map_icons/icon_target_2.png"), Vector2.ONE], # TO BE IMPLEMENTED
	CampaignRoom.TYPE.EVENT : [preload("res://resources/sprites/icons/campaign_map_icons/icon_event.png"),Vector2.ONE],
	CampaignRoom.TYPE.SHOP : [preload("res://resources/sprites/icons/campaign_map_icons/icon_coin.png"),Vector2.ONE],
	CampaignRoom.TYPE.ELITE : [preload("res://resources/sprites/icons/UnitArchetype.png"),Vector2.ONE],
	CampaignRoom.TYPE.TREASURE : [preload("res://resources/sprites/icons/campaign_map_icons/icon_gem.png"),Vector2.ONE],
	CampaignRoom.TYPE.RECRUITMENT : [preload("res://resources/sprites/icons/campaign_map_icons/army_addition_icon.png"),Vector2.ONE],
	CampaignRoom.TYPE.BOSS : [preload("res://resources/sprites/icons/unit_trait_icons/undead_icon.png"),Vector2(1.25,1.25)]
}

@onready var sprite_2d:Sprite2D = $Visuals/Sprite2D
@onready var line_2d:Line2D = $Visuals/Line2D

@onready var animation_player:AnimationPlayer = $AnimationPlayer

var available := false : set = set_available
var room : CampaignRoom : set = set_room



func set_available(new_value:bool) -> void:
	available = new_value
	if available:
		animation_player.play("highlight")
	elif not room.selected:
		animation_player.play("RESET")

func set_room(new_data:CampaignRoom) -> void:
	room = new_data
	position = room.position
	line_2d.rotation_degrees = randi_range(0,360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func show_selected() ->void:
	line_2d.modulate = Color.WHITE


#Called by the AnimationPlayer when the "select" animation finishes
func _on_map_room_selected() -> void:
	selected.emit(room)


func _on_focus_entered():
	modulate = Color.WHITE


func _on_focus_exited():
	modulate = "828282"


func _on_gui_input(event):
	if not available or not event.is_action_pressed("ui_accept") or not has_focus():
		return

	room.selected = true
	animation_player.play("select")
