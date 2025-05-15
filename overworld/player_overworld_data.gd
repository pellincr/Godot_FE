extends Resource

class_name PlayerOverworldData


@export var gold = 15050
@export var total_party_capacity = 15 #number of units the player is allowed to own
@export var available_party_capacity = 4 #number of units the player is allowed to use in dungeon
@export var total_recruits_available = 3 #number of units the player is able to purchase
@export var shop_level = 1 #level of shop associated with what upgrades are availalble for purchase

@export var total_party = []
@export var selected_party = []

@export var new_recruits = []
@export var temp_name_list = ["Craig", "Devin", "Jacob", "Porter", "Jarry"]

@export var convoy_size = 100
@export var convoy = []
#Array value -> array
#Appends the given value onto the given array
func append_to_array(arr, val):
	arr.append(val)

func get_total_party():
	return total_party
