extends Resource
class_name UnitStatusEffectDefinition

@export_subgroup("Info")
@export var name : String = ""
@export var db_key : String = ""
@export var description : String = ""
@export_subgroup("Effects")
@export var effect_type : EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.STAT
@export var application_type : EffectConstants.APPLICATION_PHASE = EffectConstants.APPLICATION_PHASE.CONSTANT
@export var effect_stats : CombatUnitStat
@export_subgroup("Visuals")
@export var icon : Texture2D
@export var map_graphic : Texture2D
