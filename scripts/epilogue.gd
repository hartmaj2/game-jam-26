extends Node2D

var final_texture = preload("res://assets/img/epilogue/final_foreground.PNG")

var textures = [
	preload("res://assets/img/epilogue/red_sitting.PNG"), #1
	preload("res://assets/img/prologue/montage/og_king_sitting_closeup_background.JPG"), #2
	preload("res://assets/img/epilogue/blue_bullying_red.PNG"), #4
	preload("res://assets/img/epilogue/blue_tilting_red.PNG"), #5
	preload("res://assets/img/epilogue/blue_tilting_empty.PNG"), #6
	preload("res://assets/img/epilogue/blue_tilting_empty.PNG"), #6
	]

var functions = [
	king_on_vulcan, #1
	king_on_vulcan_closeup, #2
	king_on_vulcan_GTFO1, #3
	king_on_vulcan_GTFO2, #4
	king_on_vulcan_GTFO3, #5
	final #6
	]

var current = -1 # SHOULD BE -1
@onready var texture = $Background
@onready var cam = $Camera2D
@onready var skip_label = $Camera2D/Label
@onready var clouds = $Make_Clouds_Invisible_Again
@onready var end_label = $Label
var started = false

func _ready() -> void:
	next()

func next():
	current+=1
	texture.texture = textures[current]
	# print(textures[current])
	functions[current].call()

func king_on_vulcan():
	$King_On_Vulkan_Background.visible=true
	texture.z_index=1
	cam.position = Vector2(960,540)
	cam.zoom = Vector2(1,1)
	await get_tree().create_timer(3).timeout
	$King_On_Vulkan_Background.visible=false
	texture.z_index=0
	next()
	
func king_on_vulcan_closeup():
	$King_On_Vulkan_Closeup_King.visible=true
	$King_On_Vulkan_Closeup_Enemy.visible=true
	await get_tree().create_timer(0.5).timeout
	var tw = get_tree().create_tween()
	tw.tween_property($King_On_Vulkan_Closeup_Enemy,"position", Vector2(0, 0), 2)
	await  tw.finished
	await get_tree().create_timer(2).timeout
	$King_On_Vulkan_Closeup_King.visible=false
	$King_On_Vulkan_Closeup_Enemy.visible=false
	next()

func king_on_vulcan_GTFO1():
	$King_On_Vulkan_Background.visible=true
	texture.z_index=1
	await get_tree().create_timer(2).timeout
	$King_On_Vulkan_Background.visible=false
	texture.z_index=0
	next()
	#GM.to_tutorial()

# other king holds the chair
func king_on_vulcan_GTFO2():
	$King_On_Vulkan_Background.visible=true
	texture.z_index=1
	await get_tree().create_timer(0.03).timeout
	$King_On_Vulkan_Background.visible=false
	texture.z_index=0
	next()

# rolling out of chair
func king_on_vulcan_GTFO3():
	$King_On_Vulkan_Background.visible=true
	texture.z_index=1
	
	$KickPath.visible = true
	var tw = get_tree().create_tween()
	tw.set_parallel(true)
	var duration = 1
	tw.tween_property($KickPath/PathFollow2D,"progress_ratio",1, duration)
	tw.tween_property($KickPath/PathFollow2D,"rotation",deg_to_rad(-100), duration)
	await  tw.finished
	
	await get_tree().create_timer(2).timeout
	next()

func final():
	#$King_On_Vulkan_Background.visible=false
	texture.visible = false
	$AnimatedSprite2D.visible = true
	#$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.sprite_frames.set_animation_loop("idle", false)
	$AnimatedSprite2D.frame = 0
	await get_tree().create_timer(2).timeout
	for i in range(1,8):
		$AnimatedSprite2D.frame = i
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	for i in range(8,17):
		$AnimatedSprite2D.frame = i
		await get_tree().create_timer(0.1).timeout
	#$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.visible = false
	texture.texture = final_texture
	texture.visible = true
	await get_tree().create_timer(3).timeout
	end_label.visible = true
	pass
	#TODO: END GAME HERE
