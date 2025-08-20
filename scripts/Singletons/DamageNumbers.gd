extends Node
const theme = preload("res://resources/themes/Damage_Numbers.tres")

signal complete()

func display_number(value:int, position:Vector2, is_critical: bool = false):
	var number = Label.new()
	number.global_position = position
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	number.text = str(value)
	number.theme = theme
	var color = "#FFF"
	if is_critical:
		color = "#B22"
		number.label_settings.font_size = 24
	number.label_settings.font_color = color
	number.label_settings.font_size = 18
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 3
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y -24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y -24, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
	complete.emit()

func display_text(value:String, position:Vector2, text_color:Color, outline_color:Color, text_size: int) :
	var display_text_object = Label.new()
	display_text_object.global_position = position
	display_text_object.z_index = 5
	display_text_object.theme = theme
	display_text_object.text = value
	#display_text.theme.set_font(font)
	display_text_object.label_settings = LabelSettings.new()
	display_text_object.label_settings.font_color = text_color
	display_text_object.label_settings.font_size = text_size
	display_text_object.label_settings.outline_color = outline_color
	display_text_object.label_settings.outline_size = 3
	
	call_deferred("add_child", display_text_object)
	
	await display_text_object.resized
	display_text_object.pivot_offset = Vector2(display_text_object.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		display_text_object, "position:y", display_text_object.position.y -24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		display_text_object, "position:y", display_text_object.position.y -24, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		display_text_object, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	display_text_object.queue_free()
	complete.emit()

func no_damage(position:Vector2):
	display_text("No Damage", position, Color.WHITE, Color.BLACK, 18)

func miss(position:Vector2):
	display_text("Miss", position, Color.WHITE, Color.BLACK, 18)

func heal(position:Vector2, value: int):
	display_text(str(value), position, Color.GREEN, Color.WEB_GREEN, 18)
