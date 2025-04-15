extends Node
class_name GridNode
	
var position: Vector2i
var g_cost : Array[float] = [INF,INF,INF,INF,INF]# The cost to reach this node
var h_cost: float = INF  # The heuristic cost (for A*), but for Dijkstra we won't use it
var f_cost: float = INF  # g_cost + h_cost (unused in Dijkstra)
var parent: GridNode = null  # The previous node in the path

static func create(p_position: Vector2i, g_cost: Array[float] = [INF,INF,INF,INF,INF]) -> GridNode:
	var instance = GridNode.new()
	instance.position = p_position
	instance.g_cost = g_cost
	return instance
