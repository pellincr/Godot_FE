extends Node


# Apply the effect
func apply_status(combat_unit: CombatUnit, status_effect):
	#add it to the unit's status effect map
	
	#if it takes place instantly process it
	pass

# Decay the status effects with the input trigger, and update unit stats accordingly
func decay_status_effects_at_trigger(combat_unit: CombatUnit, trigger):
	# get all status effects that have the decay trigger
	
	# decay them, and remove them if applicable
	
	# update the unit stats, if any status_effects have been removed
	pass

#Force removal of a status effect
func remove_status_effect(combat_unit:CombatUnit, status_effect):
	pass

#This does the status effects active effect, so it should update stats or apply damage or healing
func process_status_effect(combat_unit:CombatUnit, status_effect):
	# Does the status effect need to alter the unit's stats?
	
	#Does the status effect do damage to the unit?
	
	# 
	pass
 
