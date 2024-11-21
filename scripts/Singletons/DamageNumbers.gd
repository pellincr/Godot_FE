extends Node
##const font = preload("res://resources/fonts/CrimsonText-Bold.ttf")
const theme = preload("res://resources/themes/Damage_Numbers.tres")
func display_number(value:int, position:Vector2, is_miss: bool = false, is_critical: bool = false):
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

func display_text(value:String, position:Vector2, text_color:Color, outline_color:Color, text_size: int) :
	var display_text = Label.new()
	display_text.global_position = position
	display_text.z_index = 5
	display_text.theme = theme
	display_text.text = value
	#display_text.theme.set_font(font)
	display_text.label_settings = LabelSettings.new()
	display_text.label_settings.font_color = text_color
	display_text.label_settings.font_size = text_size
	display_text.label_settings.outline_color = outline_color
	display_text.label_settings.outline_size = 3
	
	call_deferred("add_child", display_text)
	
	await display_text.resized
	display_text.pivot_offset = Vector2(display_text.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		display_text, "position:y", display_text.position.y -24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		display_text, "position:y", display_text.position.y -24, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		display_text, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	display_text.queue_free()		

func no_damage(position:Vector2):
	display_text("No Damage", position, Color.WHITE, Color.BLACK, 18)

func miss(position:Vector2):
	display_text("Miss", position, Color.WHITE, Color.BLACK, 18)
	
