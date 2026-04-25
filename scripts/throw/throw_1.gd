extends Node2D

@export var start_at_wall = true

@onready var left_wall: StaticBody2D = $Bounds/LeftFightBarrier
@onready var right_wall: StaticBody2D = $Bounds/RightFightBarrier
@onready var camera: Camera2D = $Player/Camera2D

func _ready():
	# turn off barrier collisions at the start
	left_wall.get_node("CollisionShape2D").disabled = true
	#right_wall.get_node("CollisionShape2D").disabled = true
	if start_at_wall:
		$Player.global_position = $TriggerAreas/EnterThrowingFight/CollisionShape2D.global_position


func _on_enter_throwing_fight_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activate_barriers()


func activate_barriers():
	# turn on barrier collisions
	left_wall.get_node("CollisionShape2D").set_deferred("disabled", false)
	#right_wall.get_node("CollisionShape2D").set_deferred("disabled", false)

	# set camera limits to the barriers
	var left_x = left_wall.get_node("CollisionShape2D").global_position.x
	var right_x = right_wall.get_node("CollisionShape2D").global_position.x

	camera.limit_left = left_x
	camera.limit_right = right_x

func _on_enter_cave_body_entered(body: Node2D) -> void:
	GM.to_cave()


func _on_enter_map_scene_body_entered(body: Node2D) -> void:
	GM.to_map()
