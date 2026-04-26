extends Node2D

var textures = [preload("res://assets/img/prologue/Backgrounds.JPG"), preload("res://assets/img/prologue/montage/og_king_sitting_foreground.PNG"), preload("res://assets/img/prologue/montage/og_king_sitting_closeup_background.JPG"), preload("res://assets/img/prologue/montage/og_king_sitting_foreground.PNG"), preload("res://assets/img/trans/cave.jpg"), preload("res://assets/img/trans/death.jpg"), preload("res://assets/img/trans/village.jpg")]
var functions = [vulkan, king_on_vulcan, king_on_vulcan_closeup, king_on_vulcan_GTFO, shit1, shit2, shit3]
var current = -1
@onready var texture = $Background
@onready var cam = $Camera2D
# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Label.visible = false
		next()

func next():
	current+=1
	texture.texture = textures[current]
	functions[current].call()
	

func vulkan():
	await get_tree().create_timer(0.5).timeout
	var tw = get_tree().create_tween()
	#tw.set_parallel(true)
	tw.tween_property($Camera2D,"position",Vector2(960, 1080+540), 0.5)
	tw.tween_property($Camera2D,"zoom",Vector2(2,2), 0.5)
	await  tw.finished
	next()

func king_on_vulcan():
	$King_On_Vulkan_Background.visible=true
	texture.z_index=1
	cam.position = Vector2(960,540)
	cam.zoom = Vector2(1,1)
	await get_tree().create_timer(1).timeout
	$King_On_Vulkan_Background.visible=false
	texture.z_index=0
	next()
	
func king_on_vulcan_closeup():
	$King_On_Vulkan_Closeup_King.visible=true
	$King_On_Vulkan_Closeup_Enemy.visible=true
	await get_tree().create_timer(0.5).timeout
	var tw = get_tree().create_tween()
	tw.tween_property($King_On_Vulkan_Closeup_Enemy,"position", Vector2(0, 0), 1)
	await  tw.finished
	await get_tree().create_timer(2).timeout
	$King_On_Vulkan_Closeup_King.visible=false
	$King_On_Vulkan_Closeup_Enemy.visible=false
	$Make_Clouds_Invisible_Again.visible=false
	next()

func king_on_vulcan_GTFO():
	await get_tree().create_timer(2).timeout
	next()

func shit1():
	cam.position = Vector2(960,540)
	cam.zoom = Vector2(1,1)
	GM.to_tutorial()
	#texture.scale = Vector2(1,1)
	#print(texture.texture)
	#print()

func shit2():
	pass
	
func shit3():
	pass
	
