extends Resource
class_name Stack

var _stack : Array

func _init() -> void:
	_stack = []

func push(data) -> void:
	_stack.push_back(data)

func pop():
	assert(_stack.size() > 0, "Unable to pop data - Stack is empty")
	var data = _stack.pop_back()
	return data

func peek():
	assert(_stack.size() > 0, "Unable to peek at data - Stack is empty")
	return _stack[-1]

func get_size() -> int:
	return _stack.size()

func is_empty() -> bool:
	return _stack.size() == 0

func flush():
	_stack.clear()
