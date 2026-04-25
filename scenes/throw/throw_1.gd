extends Node2D

@export var start_at_wall = true

@onready var left_wall: StaticBody2D = $Bounds/LeftFightBarrier
@onready var right_wall: StaticBody2D = $Bounds/RightFightBarrier
@onready var camera: Camera2D = $Player/Camera2D
@onready var trajectory: Line2D = $Player/Trajectory

var fight_started = false

func _ready():
	# turn off barrier collisions at the start
	left_wall.get_node("CollisionShape2D").disabled = true
	#right_wall.get_node("CollisionShape2D").disabled = true

	trajectory.visible = false

	if start_at_wall:
		$Player.global_position = $TriggerAreas/EnterThrowingFight/CollisionShape2D.global_position


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

		trajectory.visible = true

		# await get_tree().create_timer(0.5).timeout

		body.input_locked = false


func _on_enter_cave_body_entered(body: Node2D) -> void:
	GM.to_cave()


func _on_enter_map_scene_body_entered(body: Node2D) -> void:
	GM.to_map()
