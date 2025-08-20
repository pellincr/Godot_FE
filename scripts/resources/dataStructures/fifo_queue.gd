extends RefCounted
class_name FifoQueue

# A class implementing the Queue (FIFO) data structure
# Allows for O(1) enqueueing and dequeueing of data

var _head: QueueNode
var _tail: QueueNode
var _length: int
var _max_length: int


func _init(max_length: int = INF) -> void:
	_head = null
	_tail = null
	_length = 0
	_max_length = max_length


func enqueue(data) -> void:
	assert(_length < _max_length, "Unable to enqueue data - Queue is full")
	var new_node = QueueNode.new(data)
	if _head == null:
		_head = new_node
		_tail = new_node
	else:
		_tail.next = new_node
		new_node.prev = _tail
		_tail = new_node
	_length += 1


func dequeue():
	assert(_length > 0, "Unable to dequeue data - Queue is empty")
	var data = _head.data
	_head = _head.next
	_length -= 1
	if _length == 0:
		_tail = null
	return data


func peek():
	return _head.data


func is_empty() -> bool:
	return _length == 0


func is_full() -> bool:
	return _length == _max_length


func flush():
	while _length > 0:
	#while peek() != null:
		dequeue()

class QueueNode:
	var data
	var next
	var prev

	func _init(new_data) -> void:
		data = new_data
		next = null
		prev = null
