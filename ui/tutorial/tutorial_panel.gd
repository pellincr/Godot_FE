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
	DRAFT, BATTLE_PREP, CAMPAIGN_MAP, MUNDANE_WEAPONS
}

var current_state : TUTORIAL

var tutorial_page_text : Array[String] = []

var total_pages = clampi(1,1,100)
var current_page = clampi(1,1,total_pages)



func _ready():
	instantiate_tutorial()
	grab_focus()
	update_tutorial_panel()

func instantiate_tutorial():
	match current_state:
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
			tutorial_page_text.append("In combat, it is important to choose your weapon wisely. The Mundane Weapons work as follows: Swords beat Axes, Axes beat Lances, and Lances beat Swords.")
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
	if has_focus() and event.is_action_pressed("ui_accept") and current_page == total_pages:
		tutorial_completed.emit()
		queue_free()
	if has_focus() and event.is_action_pressed("ui_back") and current_page != 1:
		current_page -= 1
		grab_focus()
		update_tutorial_panel()
	if has_focus() and event.is_action_pressed("ui_accept") and current_page != total_pages:
		current_page += 1
		grab_focus()
		update_tutorial_panel()


func _on_focus_exited():
	grab_focus()
