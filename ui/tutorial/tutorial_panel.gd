extends PanelContainer

class_name TutorialPanel

signal tutorial_completed()

@onready var tutorial_image = $TutorialPanel/MarginContainer/MainContainer/TutorialImage
@onready var tutorial_text = $TutorialPanel/MarginContainer/MainContainer/TutorialText

@onready var page_number_label = $TutorialPanel/MarginContainer/MainContainer/PageContainer/PageNumberLabel

@onready var back_container = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/BackContainer
@onready var next_container = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/NextContainer
@onready var next_label = $TutorialPanel/MarginContainer/MainContainer/PageContainer/ControlsContainer/NextContainer/NextLabel


var tutorial_page_text : Array[String] = []

var total_pages = clampi(1,1,100)
var current_page = clampi(1,1,total_pages)



func _ready():
	grab_focus()
	update_tutorial_panel()

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
