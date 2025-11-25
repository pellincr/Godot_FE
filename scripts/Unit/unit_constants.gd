extends Node
##
# Store constants used in unit based datatypes
##

const LOW_STAT_LEVEL_BAR := 3
const HIGH_STAT_LEVEL_BAR := 8
const LOW_HEALTH_STAT_LEVEL_BAR := 8
const HIGH_HEALTH_STAT_LEVEL_BAR := 20


#Unit Family determines a unit's promotion options and class skill pool
enum FAMILY 
{ ## TO BE IDEATED MORE CLASSES REFERENCE SPREAD SHEET
	ARMOR_KNIGHT,
	CAVALRY,
	SWORDSMAN,
	RANGER,
	PRIATE,
	THIEF,
	HEALER,
	ORC
}

enum FACTION 
{ ## TO BE IDEATED MORE CLASSES REFERENCE SPREAD SHEET
	MERCENARY,
	KINGDOM,
	THEOCRACY,
	LAWBREAKERS,
	CULTIST,
	SKELETAL,
	MONSTER
}

enum TRAITS 
{ ## Unique information for specific unit
	ARMORED,
	MOUNTED,
	FLIER,
	TERROR
}

enum movement_type 
{ ## How unit terrain traversal is calculated
	DEFAULT,
	HEAVY,
	MOBILE,
	MOUNTED,
	FLIER
}
