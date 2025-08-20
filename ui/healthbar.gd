extends ProgressBar

var speed = 1
var desired_value = value
var tween = null

signal finished()

func _ready():
	self.step = .001

func _process(delta):
	if(self.max_value == self.value):
		self.visible = false
	else : 
		self.visible = true
	##if desired_value != value and not tween:
		##print("tween activated")
		##activate_tween()
		pass

func activate_tween():
	if get_tree() != null:
		tween = get_tree().create_tween()
		tween.tween_property(self, "value", desired_value, 0.4)
		tween.connect("finished", tween_done)
	
func tween_done():
	tween = null
	emit_signal("finished")
