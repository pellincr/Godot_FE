class_name GoldCounter extends Label


@onready var gold_counter = $"."

#updates the text of the label to be what was given as input
func update_gold_count(gold_count) -> void:
	gold_counter.set_text(str(gold_count) + "Gold")
