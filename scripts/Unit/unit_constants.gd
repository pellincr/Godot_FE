extends Node
##
# Store constants used in unit based datatypes
##

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
	UNDEAD,
	LOCKPICK,
	MASSIVE
}

enum movement_type 
{ ## How unit terrain traversal is calculated
	DEFAULT,
	HEAVY,
	LIGHT,
	MOUNTED,
	FLIER
}
