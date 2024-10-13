class_name GoldCounter extends Panel


@onready var _gold_label := $Label as Label

#updates the text of the label to be what was given as input
func update_gold_count(gold_count) -> void:
	_gold_label.set_text("Gold:" + str(gold_count))
