extends HBoxContainer

@onready var archetype_name_label = $PanelContainer/MarginContainer/MainContainer/ArchetypeNameLabel

@onready var archetype_picks_container = $PanelContainer/MarginContainer/MainContainer/ArchetypePicksContainer
@onready var archetype_icon_container = $PanelContainer/MarginContainer/MainContainer/ArchetypeIconContainer

var archetype : ArmyArchetypeDefinition

# Called when the node enters the scene tree for the first time.
func _ready():
	if archetype:
		update_by_archetype()
	else:
		update_by_locked()

func set_name_label(name):
	archetype_name_label.text = name

func fill_archetypes_pick_container(archetype_picks: Array[armyArchetypePickDefinition]):
	for pick in archetype_picks:
		var archetype_pick_label: Label = Label.new()
		var volume = pick.volume
		archetype_pick_label.text =  str(volume) + " X " + pick.name
		archetype_pick_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		archetype_picks_container.add_child(archetype_pick_label)
		while(volume > 0):
			add_to_archetype_icon_container() #THIS WILL BE CHANGED WHEN PICKS GET THEIR ICONS
			volume-= 1

func add_to_archetype_icon_container():
	var icon = preload("res://resources/sprites/icons/UnitArchetype.png")
	var texture = TextureRect.new()
	texture.texture = icon
	archetype_icon_container.add_child(texture)

func update_by_locked():
	set_name_label("???")
	var label = Label.new()
	archetype_picks_container.add_child(label)
	label.text = "Play More to Unlock More Archetypes!"

func update_by_archetype():
	set_name_label(archetype.name)
	fill_archetypes_pick_container(archetype.archetype_picks)
