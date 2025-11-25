extends VBoxContainer
@onready var special_effect_container = $WeaponSpecialsContainer

func update_special_container(current_specials:Array[SpecialEffect]):
	var children = special_effect_container.get_children()
	for child in children:
		child.queue_free()
	for special in current_specials:
		var spec_text = special.to_string()
		var label = Label.new()
		label.text = spec_text
		special_effect_container.add_child(label)
