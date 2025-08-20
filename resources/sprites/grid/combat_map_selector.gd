extends AnimatedSprite2D
class_name CombatMapSelector 

var current_mode : MODE = MODE.DEFAULT

enum MODE {
	DEFAULT,
	COMBAT
}

func set_mode(mode : MODE):
	match mode: 
		MODE.DEFAULT:
			self.play("default")
		MODE.COMBAT:
			self.play("combat_targetting")
