extends Control

class_name UnitOverview

@onready var stats_overview_label = $VBoxContainer/StatsOverviewContainer/GradeLabelContainer/StatsOverviewLabel
@onready var growths_overview_label = $VBoxContainer/StatsOverviewContainer/GradeLabelContainer/GrowthsOverviewLabel

@onready var weapon_trait_icon_container = $VBoxContainer/WeaponTraitIconContainer


func set_stats_overview_label(grade):
	stats_overview_label.text = grade

func set_growths_overview_label(grade):
	growths_overview_label.text = grade

func set_icon_visibility(unit):
	weapon_trait_icon_container.unit = unit.get_unit_type_definition()
	weapon_trait_icon_container.set_icon_visibility()
