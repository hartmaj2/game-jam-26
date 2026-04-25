extends Node2D
var controllable = true
@onready var fade = $Canvas/Fade
@onready var map = $Canvas/Map
@onready var path_follower = $Canvas/Map/Path1/PathFollow2D
const fade_time = 0.5
var current = 0

var jumps = ["res://scenes/jump/jump1.tscn"]
var throws = ["res://scenes/throw/throw1.tscn"]
var current_scene = jumps[0]

var death_screen = preload("res://assets/img/trans/death.jpg")
var village = preload("res://assets/img/trans/village.jpg")
var cave = preload("res://assets/img/trans/cave.jpg")
@onready var paths = [$Canvas/Map/Path1, $Canvas/Map/Path2]

var fading: float = 0.5
var current_strength: float = 0.0
func trigger_shake(strength: float = 15.0, decay: float = 0.5) -> void:
	current_strength = strength
	fading = decay
	


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
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",0,fade_time)
	await tw.finished
	controllable = true
	
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
