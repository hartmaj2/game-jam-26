extends Node2D
var controllable = true
@onready var fade = $Canvas/Fade
@onready var map = $Canvas/Map
@onready var path_follower = $Canvas/Map/Path1/PathFollow2D
const fade_time = 0.2
var current_index = -1

var jumps = ["res://scenes/jump/jump1.tscn", "res://scenes/jump/jump2.tscn"]
var throws = ["res://scenes/throw/throw1.tscn","res://scenes/throw/throw2.tscn"]
var tut = "res://scenes/tutorial.tscn"
var current_scene = jumps[0]

var wind = preload("res://assets/sounds/sfx/wind.ogg")
var cave = preload("res://assets/sounds/sfx/cave.ogg")
var trans_texture = preload("res://assets/img/trans/death.jpg")
@onready var paths = [$Canvas/Map/Path1, $Canvas/Map/Path2]

var fading: float = 0.5
var current_strength: float = 0.0
func trigger_shake(strength: float = 15.0, decay: float = 0.5) -> void:
	current_strength = strength
	fading = decay

func to_tutorial():
	current_index = -1
	path_follower.progress_ratio = 0
	path_follower.reparent(paths[current_index+1])
	controllable = false
	fade.texture = cave
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = tut
	get_tree().change_scene_to_file(tut)
	fade_out()

func to_epilogue():
	await get_tree().create_timer(0.2).timeout # to not have the error appear
	get_tree().change_scene_to_file("res://scenes/epilogue.tscn")

func to_prologue():
	get_tree().change_scene_to_file("res://scenes/prologue.tscn")
	

func to_cave():
	
	controllable = false
	fade.texture = trans_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = jumps[current_index]
	get_tree().change_scene_to_file(current_scene)
	$AudioStreamPlayer.stream = cave
	$AudioStreamPlayer.play()
	fade_out()

func from_cave():
	controllable = false
	
	fade.texture = trans_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = throws[current_index]
	get_tree().change_scene_to_file(current_scene)
	$AudioStreamPlayer.stream = wind
	$AudioStreamPlayer.play()
	fade_out()

func death():
	controllable = false
	fade.texture = trans_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	get_tree().change_scene_to_file(current_scene)
	fade_out()

func fade_out():
	print("Fade out:", str(current_index))
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
	tw.tween_property(path_follower, "progress_ratio", 1.0, 0.5)
	await tw.finished
	tw = get_tree().create_tween()
	tw.tween_property(map, "modulate:a",0,fade_time)
	await tw.finished
	current_index += 1 
	path_follower.reparent(paths[min(1,current_index+1)])
	path_follower.progress_ratio = 0
	controllable = true
