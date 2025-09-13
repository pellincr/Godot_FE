extends Resource
class_name UnitStatusEffectDefinition

@export_subgroup("Info")
@export var name : String = ""
@export var db_key : String = ""
@export var description : String = ""
@export_subgroup("Overview")
@export var effect_type : EffectConstants.EFFECT_TYPE 
@export var application_type : EffectConstants.APPLICATION_PHASE = EffectConstants.APPLICATION_PHASE.CONSTANT
@export var decay_trigger: EffectConstants.DECAY_TRIGGER
@export var stacking_type : Array[EffectConstants.STACKING_METHOD]
@export_subgroup("Stats")
@export var effect_stats : CombatUnitStat #this would be at level 1
@export var effect_stacking_mult: float = 1
@export_subgroup("Visuals")
@export var icon : Texture2D
@export var map_graphic : Texture2D
