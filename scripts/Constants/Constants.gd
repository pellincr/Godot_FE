extends Node

enum UNIT_TYPE {
	INFANTRY,
	CALVARY,
	ARMORED,
	MONSTER,
	ANIMAL,
	FLYING
}

enum UNIT_MOVEMENT_CLASS {
	GENERIC,
	MOBILE,
	HEAVY,
	MOUNTED,
	FLYING
}
enum FACTION
{
	PLAYERS,
	ENEMIES,
	#FRIENDLY,
	#NOMAD
}

enum DAMAGE_TYPE 
{
	PHYSICAL,
	MAGIC
}

enum GAME_STATE{
	INITIALIZING,
	PLAYER_TURN,
	ENEMY_TURN,
	FRIENDLY_TURN,
	NOMAD_TURN,
	PAUSE,
	VICTORY,
	DEFEAT
}
enum TURN_PHASE
{
	INIT,
	IDLE,
	BEGINNING_PHASE,
	MAIN_PHASE,
	ENDING_PHASE
}
enum PLAYER_STATE
{
	INIT,
	IDLE,
	UNIT_SELECT,
	UNIT_HOVER,
	INFO,
	GAME_MENU,
	UNIT_MOVEMENT,
	UNIT_ACTION_SELECT,
	UNIT_ACTION_ITEM_SELECT,
	UNIT_ACTION_TARGET_SELECT,
	UNIT_ACTION,
	UNIT_MAJOR_ACTION,
	UNIT_ACTION_POST,
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

enum UNIT_ACTION {
	WAIT,
	ATTACK
}


enum UNIT_ACTION_STATE {
	ITEM_SELECT,
	TARGET_SELECT,
	ACTION
}
