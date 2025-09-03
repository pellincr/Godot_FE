extends Node

class_name UnitExperienceManager

const EXPERIENCE_BAR_COMPONENT = preload("res://ui/combat/unit_experience_bar/unit_experience_bar.tscn")
const LEVEL_UP_COMPONENT = preload("res://ui/combat/unit_level_up/unit_level_up.tscn")

func process_experience_gain(unit:Unit, experience_amount: int):
	print ("Enteredprocess_experience_gain")
	if (unit.experience + experience_amount >= 100):
		var experience_excess = unit.experience + experience_amount - 100
		var experience_bar = EXPERIENCE_BAR_COMPONENT.instantiate()
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
		var level_up_component = LEVEL_UP_COMPONENT.instantiate()
		await level_up_component
		$"../../CanvasLayer/UI".add_child(level_up_component)
		level_up_component.visible = false
		level_up_component.set_unit(unit)
		var level_up_stats : UnitStat = unit.get_level_up_value()
		level_up_component.set_level_up_stat_array(level_up_stats.to_array())
		level_up_component.update_fields()
		level_up_component.visible = true
		await level_up_component.update_level_up_stats()
		await get_tree().create_timer(3).timeout
		unit.apply_level_up_value(level_up_stats)
		
		level_up_component.queue_free()
		experience_bar.set_initial_value(0)
		experience_bar.set_desired_value(experience_excess)
		experience_bar.visible = true
		experience_bar.activate_tween()
		await experience_bar.finished
		experience_bar.queue_free()
		unit.experience = experience_excess
	else :
		var experience_bar = EXPERIENCE_BAR_COMPONENT.instantiate()
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
