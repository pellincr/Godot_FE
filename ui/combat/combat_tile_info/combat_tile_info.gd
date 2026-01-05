extends Control

#Terrain Top Panel
@onready var tile_index: Label = $TerrainInfoContainer/UpperTilePanel/Tile_Index
@onready var terrain_name: Label = $TerrainInfoContainer/UpperTilePanel/UpperTileContainer/TerrainName

#Terrain Bonuses
@onready var terrain_bonus_avoid: Panel = $TerrainInfoContainer/TerrainBonusAvoid
@onready var avoid_value: Label = $TerrainInfoContainer/TerrainBonusAvoid/LowerBonusContainer/HBoxContainer/Value

@onready var terrain_bonus_defense: Panel = $TerrainInfoContainer/TerrainBonusDefense
@onready var defense_value: Label = $TerrainInfoContainer/TerrainBonusDefense/LowerBonusContainer/HBoxContainer/Value

@onready var terrain_bonus_resistance: Panel = $TerrainInfoContainer/TerrainBonusResistance
@onready var resistance_value: Label = $TerrainInfoContainer/TerrainBonusResistance/LowerBonusContainer/HBoxContainer/Value

@onready var effect_prefix: Label = $TerrainInfoContainer/TerrainBonusEffect/LowerBonusContainer/HBoxContainer/Prefix
@onready var terrain_bonus_effect: Panel = $TerrainInfoContainer/TerrainBonusEffect
@onready var effect_value: Label = $TerrainInfoContainer/TerrainBonusEffect/LowerBonusContainer/HBoxContainer/Value
@onready var effect_label: Label = $TerrainInfoContainer/TerrainBonusEffect/LowerBonusContainer/HBoxContainer/Label

# Entity
@onready var entity_info_panel: Panel = $TerrainInfoContainer/EntityInfoPanel
@onready var entity_hp: Label = $TerrainInfoContainer/EntityInfoPanel/EntityHP
@onready var entity_name: Label = $TerrainInfoContainer/EntityInfoPanel/LowerBonusContainer/EntityName


@export var combat_map_tile : CombatMapTile


func update_tile(new_tile: CombatMapTile):
	self.combat_map_tile = new_tile
	update_tile_index(combat_map_tile.position)
	update_terrain_fields(combat_map_tile.terrain)
	update_entity_display(combat_map_tile.entity)

func update_terrain_fields(terrain : Terrain):
	if terrain == null:
		return
	else: 
		terrain_name.text = terrain.name
		update_terrain_resistance_visuals(terrain.resistance)
		update_terrain_avoid_visuals(terrain.avoid)
		update_terrain_defense_visuals(terrain.defense)
		update_terrain_special(terrain.effect, terrain.effect_scaling, terrain.effect_weight)

func update_terrain_resistance_visuals(res:int):
	if res == 0:
		terrain_bonus_resistance.visible = false
		return
	else : 
		terrain_bonus_resistance.visible = true
		resistance_value.text = str(res)

func update_terrain_avoid_visuals(avoid:int):
	if avoid == 0:
		terrain_bonus_avoid.visible = false
		return
	else : 
		terrain_bonus_avoid.visible = true
		avoid_value.text = str(avoid)

func update_terrain_defense_visuals(def:int):
	if def == 0:
		terrain_bonus_defense.visible = false
		return
	else : 
		terrain_bonus_defense.visible = true
		defense_value.text = str(def)

func update_terrain_special(effect : Terrain.TERRAIN_EFFECTS, effect_scaling : Terrain.EFFECT_SCALING, effect_weight :int):
	match effect:
		Terrain.TERRAIN_EFFECTS.NONE: 
			terrain_bonus_effect.visible = false
			return
		Terrain.TERRAIN_EFFECTS.HEAL: 
			terrain_bonus_effect.visible = true
			effect_prefix.text = "+"
		Terrain.TERRAIN_EFFECTS.DAMAGE: 
			effect_prefix.text = "-"
			terrain_bonus_effect.visible = true
	match effect_scaling:
		Terrain.EFFECT_SCALING.FLAT:
			effect_value.text = str(effect_weight)
		Terrain.EFFECT_SCALING.PERCENTAGE:
			effect_value.text = "%" + str(effect_weight)

func update_tile_index(grid_position : Vector2i):
	tile_index.text = str(grid_position.x) + " , " + str(grid_position.y)

func update_entity_display(entity : CombatEntity):
	if entity == null:
		entity_info_panel.visible = false
		return
	else :
		if entity.active:
			entity_info_panel.visible = true
			entity_name.text = entity.name
			if entity.interaction_type == mapEntityDefinition.TYPE.DEBRIS or entity.interaction_type == mapEntityDefinition.TYPE.BREAKABLE_TERRAIN:
				entity_hp.text = str(entity.hp) + "HP"
				entity_hp.visible = true
			else :
				entity_hp.visible = false
	pass
