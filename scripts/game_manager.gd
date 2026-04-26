extends Node2D
var controllable = true
@onready var fade = $Canvas/Fade
@onready var map = $Canvas/Map
@onready var path_follower = $Canvas/Map/Path1/PathFollow2D
const fade_time = 1
var current_index = -1

var jumps = ["res://scenes/jump/jump1.tscn", "res://scenes/jump/jump2.tscn"]
var throws = ["res://scenes/throw/throw1.tscn","res://scenes/throw/throw2.tscn"]
var tut = "res://scenes/tutorial.tscn"
var current_scene = jumps[0]

var wind = preload("res://assets/sounds/sfx/wind.ogg")
var cave = preload("res://assets/sounds/sfx/cave.ogg")
var death_texture = preload("res://assets/img/trans/death.png")
var cave_texture = preload("res://assets/img/trans/cave.png")
var village_texture = preload("res://assets/img/trans/village.png")
@onready var paths = [$Canvas/Map/Path1, $Canvas/Map/Path2, $Canvas/Map/Path3]

var fading: float = 0.5
var current_strength: float = 0.0

signal crown_collected
var crowns_collected = 0

const path_base = "res://assets/img/throw/crown_"
var crown_sprites = [preload(path_base + "1_a.PNG"),preload(path_base + "2_a.PNG"),preload(path_base + "3_a.PNG"),preload(path_base + "4_a.PNG")]

signal trigger_handle_labels

func trigger_shake(strength: float = 15.0, decay: float = 0.5) -> void:
	current_strength = strength
	fading = decay

func to_tutorial():
	$Music.play()
	current_index = -1
	path_follower.progress_ratio = 0
	path_follower.reparent(paths[current_index+1])
	controllable = false
	fade.texture = cave_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = tut
	get_tree().change_scene_to_file(tut)
	fade_out()

func to_epilogue():
	$Music.stop()
	await get_tree().create_timer(0.2).timeout # to not have the error appear
	get_tree().change_scene_to_file("res://scenes/epilogue.tscn")

func to_prologue():
	get_tree().change_scene_to_file("res://scenes/prologue.tscn")
	

func to_cave():
	
	controllable = false
	fade.texture = cave_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = jumps[current_index]
	get_tree().change_scene_to_file(current_scene)
	$Ambient.stream = cave
	$Ambient.play()
	$Music.stop()
	fade_out()

func from_cave():
	controllable = false
	
	fade.texture = village_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time)
	await tw.finished
	current_scene = throws[current_index]
	get_tree().change_scene_to_file(current_scene)
	$Ambient.stream = wind
	$Ambient.play()
	$Music.play()
	fade_out()

func death():
	controllable = false
	fade.texture = death_texture
	var tw = get_tree().create_tween()
	tw.tween_property(fade, "modulate:a",1,fade_time/2)
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
	print("Current index:", str(current_index))
	controllable = false
	var tw = get_tree().create_tween()
	tw.tween_property(map, "modulate:a",1,fade_time)
	await tw.finished
	tw = get_tree().create_tween()
	tw.tween_property(path_follower, "progress_ratio", 1.0, 1.5)
	await tw.finished
	tw = get_tree().create_tween()
	tw.tween_property(map, "modulate:a",0,fade_time)
	await tw.finished
	current_index += 1
	if current_index <= 1:
		path_follower.reparent(paths[current_index+1])
		path_follower.progress_ratio = 0
	controllable = true

func collect_crown():
	path_follower.get_node("Player/Crown/Sprite2D").texture = crown_sprites[GM.crowns_collected]
	crowns_collected += 1
	crown_collected.emit()
