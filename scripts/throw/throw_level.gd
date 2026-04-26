extends Node2D

@export var start_at_wall = false

@onready var left_wall: StaticBody2D = $Bounds/LeftFightBarrier
@onready var right_wall: StaticBody2D = $Bounds/RightFightBarrier
@onready var camera: Camera2D = $Player/Camera2D

var fight_started = false

func _ready():
	# turn off barrier collisions at the start
	left_wall.get_node("CollisionShape2D").disabled = true
	#right_wall.get_node("CollisionShape2D").disabled = true

	if start_at_wall:
		$Player.global_position = $TriggerAreas/EnterThrowingFight/CollisionShape2D.global_position

func _physics_process(_delta: float) -> void:
	var offset = Vector2(0,0)
	var current_strength = GM.current_strength
	if GM.current_strength > 0.0:
		
		offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
		camera.offset = offset
	GM.current_strength -=GM.fading*float(current_strength>0)

func disable_right_wall_and_camera_limits():
	get_node("Player").input_locked = true
	right_wall.get_node("CollisionShape2D").set_deferred("disabled", true)
	camera.set_target(get_node("Player").global_position)
	camera.limit_right = 9600
	await get_tree().create_timer(1.5).timeout
	get_node("Player").input_locked = false

func _on_enter_throwing_fight_body_entered(body: Node2D) -> void:
	if fight_started:
		return
	if body.is_in_group("player"):
		fight_started = true
		body.input_locked = true

		# turn on barrier collision
		left_wall.get_node("CollisionShape2D").set_deferred("disabled", false)

		# set camera limits to the barriers
		var left_x = left_wall.get_node("CollisionShape2D").global_position.x
		var right_x = right_wall.get_node("CollisionShape2D").global_position.x

		camera.set_target(Vector2((left_x + right_x) / 2, camera.global_position.y))
		await get_tree().create_timer(1).timeout

		camera.limit_left = left_x
		camera.limit_right = right_x

		# await get_tree().create_timer(0.5).timeout

		body.input_locked = false


func _on_enter_cave_body_entered(_body: Node2D) -> void:
	match GM.current_index:
		0:
			print("Throw1")
			GM.to_cave()
		1:
			print("Throw2")
			GM.to_cave()
		2:
			print("Epilogue")
			GM.to_epilogue()
		_:
			print("Unknown cave index: ", GM.current_index)


func _on_enter_map_scene_body_entered(_body: Node2D) -> void:
	GM.to_map()
