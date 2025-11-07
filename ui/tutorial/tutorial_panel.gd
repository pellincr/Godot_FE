extends PanelContainer

class_name TutorialPanel

signal tutorial_completed()

@onready var tutorial_image = $TutorialPanel/MarginContainer/MainContainer/TutorialImage
@onready var tutorial_text = $TutorialPanel/MarginContainer/MainContainer/TutorialText

@onready var page_number_label = $TutorialPanel/MarginContainer/MainContainer/PageContainer/PageNumberLabel

@onready var back_container = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/BackContainer
@onready var next_container = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/NextContainer
@onready var next_label = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/NextContainer/NextLabel

enum TUTORIAL{
	HOW_TO_PLAY,
	DRAFT, BATTLE_PREP, CAMPAIGN_MAP, 
	MUNDANE_WEAPONS, MAGIC_WEAPONS, WEAPON_CYCLE, WEAPON_EFFECTIVENESS,
	SUPPORT_ACTIONS,STAFFS,BANNERS,
	TERRAIN, MAP_ENTITY,
	DEFEAT_ALL_ENEMIES, SIEZE_LANDMARK,DEFEAT_BOSSES,SURVIVE_TURNS
}

var current_state : TUTORIAL

var tutorial_page_text : Array[String] = []

var total_pages = clampi(1,1,100)
var current_page = clampi(1,1,total_pages)



func _ready():
	instantiate_tutorial()
	grab_focus()
	update_tutorial_panel()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		tutorial_completed.emit()
		queue_free()

func instantiate_tutorial():
	match current_state:
		TUTORIAL.HOW_TO_PLAY:
			tutorial_page_text.append("How to play! If you're new to the game this is an important step to learn. So let's go over the basics.")
			tutorial_page_text.append("Understanding your party. Each time you enter a battle, you will have a certain amount of units under your control. Each of these units can move once and use one action per turn.")
			tutorial_page_text.append("You can decide whether or not to use those actions or to simply wait for a better moment to strike. Once you're satisfied with your turn, you may end your turn and wait for the enemies to move")
		TUTORIAL.DRAFT:
			tutorial_page_text.append("Welcome to your first Campaign! The first part of every campaign is the army draft. Your first unit, and perhaps most important, will be the commander.")
			tutorial_page_text.append("After you select the Commander of your Army, you will select the archetypes you want your army to be built out of.")
			tutorial_page_text.append("Each Archetype will allow you to select from the units and items you have unlocked that fit the description.")
			tutorial_page_text.append("Once all archetypes are selected, you may select the units that are right for you and get ready to play")
		TUTORIAL.BATTLE_PREP:
			tutorial_page_text.append("This is the Battle Preparation Screen. Before every battle you enter, you will be able to adjust your units and send a select group of them to battle.")
			tutorial_page_text.append("The top of the screen displays the amount of units you are allowed to take on the current mission and how many units you have currently selected.")
			tutorial_page_text.append("By pressing the toggle buttons, you will be able to see either your total party, or the items you have in your convoy.")
			tutorial_page_text.append("Sell, equip, and trade items between units to make sure your party is ready for battle!")
		TUTORIAL.CAMPAIGN_MAP:
			tutorial_page_text.append("This is the Campaign Map Screen. You will navigate this map full of battles and encounters to make your way to the boss at the end.")
			tutorial_page_text.append("Each symbol shows a different type of encounter including battles, treasure, shops, events, and elites.")
			tutorial_page_text.append("Choose your path wisely for once you start down the road you may only go to the spots connected to your selected event.")
		TUTORIAL.MUNDANE_WEAPONS:
			tutorial_page_text.append("There are 3 types of Mundane Weapons: Swords, Axes, and Lances.")
			tutorial_page_text.append("In combat, it is important to choose your weapon wisely. The Mundane Weapons work as follows: Swords beats Axes, Axes beats Lances, and Lances beats Swords.")
		TUTORIAL.MAGIC_WEAPONS:
			tutorial_page_text.append("There are 3 types of Magic Weapons: Nature, Light, and Dark.")
			tutorial_page_text.append("In combat, it is important to choose your weapon wisely. The Magic Weapons work as follows: Nature beats Light, Light beats Dark, and Dark beats Nature.")
		TUTORIAL.WEAPON_CYCLE:
			tutorial_page_text.append("There are 4 main weapon types a unit can use: Mundane, Nimble, Magic, and Defensive.")
			tutorial_page_text.append("In combat, it is important to choose your weapon wisely. The Weapon Cycle works as follows: Mundane beats Nimble, Nimble beats Magic, Magic beats Defensive, and Defensive beats Mundane.")
		TUTORIAL.WEAPON_EFFECTIVENESS:
			tutorial_page_text.append("Certain weapons are more effective against certain unit types than others. For example, bows are strong against fliers and rapiers are strong against Heavy Units. Equip your items for each battle wisely.")
		TUTORIAL.SUPPORT_ACTIONS:
			tutorial_page_text.append("In combat, it is important to think carefully before each action you take. Outside of just attacking enemies, there are other actions you can do to better prepare your units.")
			tutorial_page_text.append("Shove: If you want to move a unit to a safer position, but cant move any further, you can use another unit to shove the initial unit 1 square away.")
			tutorial_page_text.append("Item Use: there are certain items, such as potions that a unit can use that provide a beneficial effect. Try using the potion in your commanders inventory to heal them back to full.")
		TUTORIAL.STAFFS:
			tutorial_page_text.append("Certain units have the ability to use staffs to harness their magical ability. Different staffs have different purposes, so be sure to plan accordingly. Try using the healer to heal your commander to full.")
		TUTORIAL.BANNERS:
			pass
		TUTORIAL.TERRAIN:
			tutorial_page_text.append("Not all terrain will be equal in combat. Each tile provides different stat bonuses to the units standing on them.")
			tutorial_page_text.append("However be careful! Certain units find it more difficult to move through terrain while others are able to move more freely.")
		TUTORIAL.MAP_ENTITY:
			tutorial_page_text.append("There will be certian type of terriain that units will be able to interact with. Some examples are breakable walls, doors, and chests. Make sure to keep your eye out and move your selector over anything that may look interactable")
		TUTORIAL.DEFEAT_ALL_ENEMIES:
			tutorial_page_text.append("There are a few different ways a battle can be completed, it is based on the battle you are in.")
			tutorial_page_text.append("In this battle, the goal is to kill all enemies on the map. Kill the enemies and proceed with victory!")
		TUTORIAL.SIEZE_LANDMARK:
			tutorial_page_text.append("There are a few different ways a battle can be completed, it is based on the battle you are in.")
			tutorial_page_text.append("In this battle, the goal is to sieze the designated landmark. In this case, the landmark is the throne. Move a unit there and press sieze!")
		TUTORIAL.DEFEAT_BOSSES:
			tutorial_page_text.append("There are a few different ways a battle can be completed, it is based on the battle you are in.")
			tutorial_page_text.append("In this battle, the goal is to kill all of the bosses on the map. Kill the enemies and proceed with victory!")
		TUTORIAL.SURVIVE_TURNS:
			tutorial_page_text.append("There are a few different ways a battle can be completed, it is based on the battle you are in.")
			tutorial_page_text.append("In this battle, the goal is to survive until the turn count is up.")
	total_pages = tutorial_page_text.size()


func set_tutorial_text(text:String):
	tutorial_text.text = text

func set_next_label_text(text):
	next_label.text = text

func set_tutorial_image(texture:Texture2D):
	tutorial_image.texture = texture

func set_page_number_label():
	page_number_label.text = str(current_page) + "/" + str(total_pages)


func set_control_sub_container_visibility(container, vis):
	container.visible = vis



func set_control_sub_container_visibility_by_page():
	if total_pages == 1:
		#If there is only one page for the given tutorial
		only_page_controls()
	else:
		if current_page < total_pages:
			#if the current page is not at the last page of the tutorial
			if current_page == 1:
				#if the current page is on the first page of the tutorial(no back button available)
				first_page_controls()
			else:
				#if the current page is in the middle of the tutorial pages
				middle_page_controls()
		else:
			#if the current page is at the last page of the tutorial
			last_page_controls()

func only_page_controls():
	set_control_sub_container_visibility(back_container,false)
	set_control_sub_container_visibility(next_container,true)
	set_next_label_text("Close")

func first_page_controls():
	set_control_sub_container_visibility(back_container,false)
	set_control_sub_container_visibility(next_container,true)
	set_next_label_text("Next")

func middle_page_controls():
	set_control_sub_container_visibility(back_container,true)
	set_control_sub_container_visibility(next_container,true)
	set_next_label_text("Next")

func last_page_controls():
	set_control_sub_container_visibility(back_container,true)
	set_control_sub_container_visibility(next_container,true)
	set_next_label_text("Close")

func update_tutorial_panel():
	set_page_number_label()
	set_control_sub_container_visibility_by_page()
	if !(current_page > tutorial_page_text.size()):
		set_tutorial_text(tutorial_page_text[current_page-1])

func _on_gui_input(event):
	print(str(current_page))
	if event.is_action_pressed("ui_accept"):
		if current_page >= total_pages:
			tutorial_completed.emit()
			queue_free()
		else:
			current_page += 1
			grab_focus()
			update_tutorial_panel()
		AudioManager.play_sound_effect("menu_confirm")
	if event.is_action_pressed("ui_back") and current_page != 1:
		current_page -= 1
		grab_focus()
		update_tutorial_panel()
		AudioManager.play_sound_effect("menu_back")

func _on_focus_exited():
	grab_focus()
