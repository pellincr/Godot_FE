extends Resource
class_name UnitCharacter

@export var name= ""
@export var level : int = 1
@export var stats : UnitStat
@export var growths : UnitStat
@export var bonus_usable_weapon_types : Array[ItemConstants.WEAPON_TYPE] = []
@export var icon: Texture2D
@export var map_sprite: Texture2D

func update_growths(update_stat: UnitStat):
	self.growths.hp = self.growths.hp  + update_stat.hp
	self.growths.strength = self.growths.strength + update_stat.strength
	self.growths.magic = self.growths.magic + update_stat.magic
	self.growths.skill = self.growths.skill + update_stat.skill
	self.growths.speed = self.growths.speed + update_stat.speed
	self.growths.luck = self.growths.luck + update_stat.luck
	self.growths.defense = self.growths.defense + update_stat.defense
	self.growths.resistance = self.growths.resistance + update_stat.resistance
	self.growths.movement = self.growths.movement + update_stat.movement
	self.growths.constitution = self.growths.constitution + update_stat.constitution
	self.growths.defense = self.growths.defense + update_stat.defense

func update_stats(update_stat: UnitStat):
	self.stats.hp = self.stats.hp  + update_stat.hp
	self.stats.strength = self.stats.strength + update_stat.strength
	self.stats.magic = self.stats.magic + update_stat.magic
	self.stats.skill = self.stats.skill + update_stat.skill
	self.stats.speed = self.stats.speed + update_stat.speed
	self.stats.luck = self.stats.luck + update_stat.luck
	self.stats.defense = self.stats.defense + update_stat.defense
	self.stats.resistance = self.stats.resistance + update_stat.resistance
	self.stats.movement = self.stats.movement + update_stat.movement
	self.stats.constitution = self.stats.constitution + update_stat.constitution
	self.stats.defense = self.stats.defense + update_stat.defense
