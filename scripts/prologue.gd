extends Node2D

var textures = [preload("res://assets/img/prologue/prologue.jpg"), preload("res://assets/img/trans/cave.jpg"), preload("res://assets/img/trans/death.jpg"), preload("res://assets/img/trans/village.jpg")]
var functions = [vulkan, shit1, shit2, shit3]
var current = -1
@onready var texture = $TextureRect
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
	await get_tree().create_timer(0.1).timeout
	var tw = get_tree().create_tween()
	#tw.set_parallel(true)
	tw.tween_property($Camera2D,"position",Vector2(960, 1080+540), 0.3)
	tw.tween_property($Camera2D,"zoom",Vector2(2,2), 0.5)
	await  tw.finished
	next()

func shit1():
	cam.position = Vector2(960,540)
	cam.zoom = Vector2(1,1)
	GM.to_cave()
	#texture.scale = Vector2(1,1)
	#print(texture.texture)
	#print()

func shit2():
	pass
	
func shit3():
	pass
	
