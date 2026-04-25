extends CharacterBody2D

@export var speed: float = 300.0
@export var rock_scene: PackedScene
@export var health: int = 3

@onready var pickup_area: Area2D = $PickupArea
@onready var trajectory: Line2D = $Trajectory

var nearby_rocks: Array[Node] = []
var rocks_picked: int = 0

var throw_speed := 1_250
var aim_angle := 1.5 # radians
var min_angle := deg_to_rad(-90)
var max_angle := deg_to_rad(90)
var angle_speed := 0.5

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()
	update_trajectory()

func _process(delta):
	if Input.is_action_pressed("aim_up"):
		aim_angle -= angle_speed * delta
		print("aim angle: ", aim_angle)
	if Input.is_action_pressed("aim_down"):
		aim_angle += angle_speed * delta
		print("aim angle: ", aim_angle)
	aim_angle = clamp(aim_angle, min_angle, max_angle)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		print("throw")
		throw_rock()
	if event.is_action_pressed("pickup"):
		print("pickup")
		pickup_nearest_rock()
	if event.is_action_pressed("debug_print"):
		print("---DEBUG---")
		print("nearby rocks: ",nearby_rocks)
		print("rocks picked: " ,rocks_picked)

func update_trajectory():
	trajectory.global_position = Vector2.ZERO
	var points = []
	var pos = global_position
	var dir = Vector2.UP.rotated(aim_angle).normalized()
	var vel = dir * throw_speed
	var gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var dt = 1.0 / Engine.physics_ticks_per_second

	for i in range(180):
		vel += gravity * dt
		pos += vel * dt
		if i % 3 == 0:
			points.append(pos)
		points.append(pos)

	trajectory.points = points
	
# THROWING ROCKS
	
func throw_rock():
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	var dir = Vector2.UP.rotated(aim_angle).normalized()
	rock.initiate_rock(global_position,throw_speed,dir)
	
# HANDLING PICKUPS
func _on_pickup_area_area_entered(area: Area2D) -> void:
	print("entered")
	if area.is_in_group("rocks"):
		nearby_rocks.append(area)

func _on_pickup_area_area_exited(area: Area2D) -> void:
	print("exited")
	if area.is_in_group("rocks"):
		nearby_rocks.erase(area)

func pickup_nearest_rock() -> void:
	if nearby_rocks.is_empty():
		return

	var rock := nearby_rocks[0]
	nearby_rocks.erase(rock)

	rock.get_parent().queue_free()
	rocks_picked += 1

func take_damage(amount: int = 1):
	print("Player took damage: ", amount)
	health -= amount
	if health <= 0:
		queue_free()
