extends Node

class_name UnitExperienceManager

const experience_bar = preload("res://ui/combat_map_view/unit_experience_bar/unit_experience_bar.tscn")
const level_up_component = preload("res://ui/combat_map_view/unit_level_up/unit_level_up.tscn")

func process_experience_gain(unit:Unit, experience_amount: int):
	print ("Enteredprocess_experience_gain")
	if (unit.experience + experience_amount >= 100):
		var experience_excess = unit.experience + experience_amount - 100
		var experience_bar = experience_bar.instantiate()
		await experience_bar
		$"../../CanvasLayer/UI".add_child(experience_bar)
		experience_bar.visible = false
		experience_bar.set_initial_value(unit.experience)
		experience_bar.set_desired_value(100)
		experience_bar.visible = true
		experience_bar.activate_tween()
		await experience_bar.finished
		experience_bar.visible = false
		##level up fan fare goes here
		var level_up_component = level_up_component.instantiate()
		await level_up_component
		$"../../CanvasLayer/UI".add_child(level_up_component)
		level_up_component.visible = false
		level_up_component.set_unit(unit)
		if(unit.uses_custom_growths):
			level_up_component.set_level_up_stat_array(unit.level_up_player())
		else :
			level_up_component.set_level_up_stat_array(unit.level_up_generic())
		level_up_component.update_fields()
		level_up_component.visible = true
		await get_tree().create_timer(3).timeout
		level_up_component.queue_free()
		experience_bar.set_initial_value(0)
		experience_bar.set_desired_value(experience_excess)
		experience_bar.visible = true
		experience_bar.activate_tween()
		await experience_bar.finished
		experience_bar.queue_free()
		unit.experience = experience_excess
	else :
		var experience_bar = experience_bar.instantiate()
		await experience_bar
		$"../../CanvasLayer/UI".add_child(experience_bar) 
		experience_bar.visible = false
		experience_bar.set_initial_value(unit.experience)
		experience_bar.set_desired_value(unit.experience + experience_amount)
		experience_bar.visible = true
		experience_bar.activate_tween()
		await experience_bar.finished
		experience_bar.queue_free()
		unit.experience = unit.experience + experience_amount
	print ("Exit process_experience_gain")
