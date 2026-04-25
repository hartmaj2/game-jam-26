extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GM.current = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): GM.to_cave()

func _on_button_pressed() -> void:
	GM.to_cave()
