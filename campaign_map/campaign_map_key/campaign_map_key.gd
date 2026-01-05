extends Control


@onready var boss_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/BossContainer/BossIcon
@onready var key_battle_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/KeyBattleContainer/KeyBattleIcon
@onready var battle_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/BattleContainer/BattleIcon
@onready var event_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/EventContainer/EventIcon
@onready var treasure_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TreasureContainer/TreasureIcon
@onready var recruit_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/RecruitContainer/RecruitIcon

func _ready() -> void:
	update_all_icons()

func update_all_icons():
	var boss_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.BOSS][0]
	boss_icon.texture = boss_texture
	var key_battle_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.KEY_BATTLE][0]
	key_battle_icon.texture = key_battle_texture
	var battle_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.BATTLE][0]
	battle_icon.texture = battle_texture
	var event_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.EVENT][0]
	event_icon.texture = event_texture
	var treasure_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.TREASURE][0]
	treasure_icon.texture = treasure_texture
	var recruitment_texture = CampaignMapRoom.ICONS[CampaignRoom.TYPE.RECRUITMENT][0]
	recruit_icon.texture = recruitment_texture
	
