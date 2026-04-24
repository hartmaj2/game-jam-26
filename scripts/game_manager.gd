extends Node2D
var controllable = true
@onready var fade = $Canvas/Fade
var current = 0
var jumps = ["res://scenes/jump1.tscn"]
var throws = ["res://scenes/throw1.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func to_cave():
	controllable = false
	fade.color = Color(0,0,0,0)
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "color:a",1,1)
	await tw.finished
	get_tree().change_scene_to_file(jumps[current])
	fade_out()

func to_map():
	controllable = false
	fade.color = Color(0,0,0,0)
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "color:a",1,1)
	await tw.finished
	fade_out()

func from_cave():
	controllable = false
	fade.color = Color(1,1,1,0)
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "color:a",1,1)
	await tw.finished
	get_tree().change_scene_to_file(throws[current])
	fade_out()

func fade_out():
	print("fade out")
	controllable = true
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "color:a",0,1)
