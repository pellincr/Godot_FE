extends Node

enum FACTION
{
	PLAYERS, # Player faction
	ENEMIES, # Enemy Faction
	FRIENDLY, # Ally Faction
	NOMAD, # Attack all faction
	TERRAIN, # Used for Attackable Terrain
	NULL
}

enum COMBAT_MAP_STATE
{
	INITIALIZING,
	PLAYER_TURN,
	AI_TURN,
	PAUSE,
	PROCESSESING,
	VICTORY,
	DEFEAT
}

enum TURN_PHASE
{
	INITIALIZING, # When game is initializing
	IDLE, #Awaiting further input -- In Menu? ** Verify
	BEGINNING_PHASE, #The phase before player input
	MAIN_PHASE, #Phase used for all player input
	ENDING_PHASE #After player has ended, (end of turn effects)
}

enum PLAYER_STATE
{
	INITIALIZING, # Initializing the game
	IDLE, # Awaiting further input
	UNIT_SELECT,
	UNIT_INFO,
	UNIT_MOVEMENT,
	UNIT_ACTION_SELECT,
	UNIT_INVENTORY,
	UNIT_ACTION_ENTER,
	UNIT_ACTION_ITEM_SELECT,
	UNIT_ACTION_TARGET_SELECT,
	UNIT_ACTION_OPTION_SELECT,
	UNIT_ACTION,
	UNIT_ACTION_COMPLETE,
	END
}

enum VICTORY_CONDITION
{
	DEFEAT_ALL,
	DEFEAT_BOSS,
	CAPTURE_TILE,
	DEFEND_TILE,
	SURVIVE_TURNS
}


enum UNIT_ACTION_STATE { ##REWRITE THIS LOGIC
	ITEM_SELECT,
	TARGET_SELECT,
	OPTION_SELECT,
	ACTION
}

enum UNIT_AI_TYPE {
	DEFAULT, #Attack and Move
	ATTACK_IN_RANGE, #Attack in move range
	DEFEND_POINT #No Move, only attack in weapon attack range
}
