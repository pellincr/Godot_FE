extends Control

class_name UnitOverview

@onready var stats_overview_label = $VBoxContainer/StatsOverviewContainer/GradeLabelContainer/StatsOverviewLabel
@onready var growths_overview_label = $VBoxContainer/StatsOverviewContainer/GradeLabelContainer/GrowthsOverviewLabel


func set_stats_overview_label(grade):
	stats_overview_label.text = grade

func set_growths_overview_label(grade):
	growths_overview_label.text = grade
