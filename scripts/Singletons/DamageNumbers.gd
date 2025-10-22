extends Node
const theme = preload("res://resources/themes/Damage_Numbers.tres")

signal complete()

func display_number(value:int, position:Vector2, is_critical: bool = false):
	var number = RichTextLabel.new()
	number.global_position = position
	number.z_index = 10
	number.z_as_relative = false
	number.scroll_active = false
	number.fit_content = true
	number.clip_contents = false
	number.autowrap_mode = TextServer.AUTOWRAP_OFF
	#number.label_settings = LabelSettings.new()
	number.bbcode_enabled = true
	number.theme = theme
	if is_critical:
		number.text = "[font_size={32}][color=#B22][shake]" +str(value) +"![/shake][/color][/font_size]"
	else:
		number.text = str(value)
	#var color = "#FFF"
	#if is_critical:
	#	color = "#B22"
	#number.label_settings.font_size = 24
	#number.label_settings.font_color = color
	#number.label_settings.font_size = 18
	#number.label_settings.outline_color = "#000"
	#number.label_settings.outline_size = 3
	
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
	).set_ease(Tween.EASE_IN).set_delay(0.75)
	
	await tween.finished
	number.queue_free()
	complete.emit()

func display_text(value:String, position:Vector2, text_color:Color, outline_color:Color, text_size: int) :
	var text = RichTextLabel.new()
	text.global_position = position
	text.z_index = 10
	text.z_as_relative = false
	text.scroll_active = false
	text.fit_content = true
	text.clip_contents = false
	text.autowrap_mode = TextServer.AUTOWRAP_OFF
	text.bbcode_enabled = true
	text.theme = theme
	text.text = "[font_size={" + str(text_size) + "}][color=#" + str(text_color.to_html(false))+ "]" +str(value) +"[/color][/font_size]"
	call_deferred("add_child", text)
	
	await text.resized
	text.pivot_offset = Vector2(text.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		text, "position:y", text.position.y -24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		text, "position:y", text.position.y -24, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		text, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	text.queue_free()
	complete.emit()

func no_damage(position:Vector2):
	display_text("No Damage", position, Color.WHITE, Color.BLACK, 18)

func miss(position:Vector2):
	display_text("[wave amp=100.0 freq=2.0 connected=1]Miss[/wave]", position, Color.WHITE, Color.BLACK, 18)

func heal(position:Vector2, value: int):
	display_text(str(value), position, Color.GREEN, Color.WEB_GREEN, 18)


func display_number_old(value:int, position:Vector2, is_critical: bool = false):
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
