extends Node

enum EFFECT_TYPE {
	NONE,
	BUFF,
	DEBUFF,
	HEAL, #USED IN SUPPORT ACTION
}

enum APPLICATION_PHASE {
	CONSTANT, #Generic stat up
	ON_DECAY, #Regen, heals when the proce decays
}

# When does the stack decay?
enum DECAY_TRIGGER {
	END_OF_TURN,
	START_OF_NEXT_TURN,
	ON_COMBAT_EXCHANGE_COMPLETE,
	ON_DAMAGE_TAKEN,
	NONE
}

enum STACKING_METHOD {
	DURATION,
	INTENSITY,
	NONE
}
