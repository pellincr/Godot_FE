extends Node


var game_app_id = 480 #480 is spacewar a default game in steamworks

func _init():
	var response := Steam.steamInitEx(game_app_id,true)
	print(response)
	
	var username : String = Steam.getPersonaName()
	print(username)
	
	var steam_id := Steam.getSteamID()
	print(steam_id)
