extends Node2D

@onready var pick_label = $"PickRockLabel"
@onready var throw_label = $"ThrowRockLabel"

func make_visible_pick():
	pick_label.visible = true
	throw_label.visible = false

func make_visible_throw():
	pick_label.visible = false
	throw_label.visible = true

func make_invisible_labels():
	pick_label.visible = false
	throw_label.visible = false
