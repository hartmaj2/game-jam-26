extends Node2D
var controllable = true
@onready var fade = $Canvas/Fade
@onready var map = $Canvas/Map
@onready var path_follower = $Canvas/Map/Path1/PathFollow2D
const fade_time = 1.5
var current = 0

var jumps = ["res://scenes/jump1.tscn"]
var throws = ["res://scenes/throw1.tscn"]
var current_scene = jumps[0]

var death_screen = preload("res://assets/img/death.jpg")
var village = preload("res://assets/img/village.jpg")
var cave = preload("res://assets/img/cave.jpg")
@onready var paths = [$Canvas/Map/Path1, $Canvas/Map/Path2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func to_cave():
	controllable = false
	fade.texture = cave
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = jumps[current]
	get_tree().change_scene_to_file(current_scene)
	fade_out()

func from_cave():
	controllable = false
	fade.texture = village
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = throws[current]
	get_tree().change_scene_to_file(current_scene)
	fade_out()

func death():
	controllable = false
	fade.texture = death_screen
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	get_tree().change_scene_to_file(current_scene)
	fade_out()

func fade_out():
	controllable = true
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",0,fade_time)
	
func to_map():
	controllable = false
	var tw = get_tree().create_tween()
	tw.tween_property(map, "modulate:a",1,fade_time)
	await tw.finished
	tw = get_tree().create_tween()
	tw.tween_property(path_follower, "progress_ratio", 1.0, 3.0)
	await tw.finished
	tw = get_tree().create_tween()
	tw.tween_property(map, "modulate:a",0,fade_time)
	await tw.finished
	path_follower.reparent(paths[1-current])
	path_follower.progress_ratio = 0
	controllable = true
	#fade_out()
