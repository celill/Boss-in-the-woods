extends Control

@onready var hp_bar = $HPBar
@onready var xp_bar = $XPBar
@onready var level_label = $LevelLabel
@onready var hp_label = $HPBar/Label

func update_hp(current, max_hp):
	hp_bar.value = (current / max_hp) * 100
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]

func update_xp(current, needed):
	xp_bar.value = (float(current) / needed) * 100

func update_level(lvl):
	level_label.text = "LEVEL " + str(lvl)
