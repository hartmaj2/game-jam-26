extends CharacterBody2D

@export var speed: float = 600.0
@export var rock_scene: PackedScene
@export var health: int = 1

@onready var pickup_area: Area2D = $PickupArea
@onready var trajectory: Line2D = $Trajectory


const path_base = "res://assets/img/throw/stickman_rock"
var sprites = [preload(path_base + "0.png"),preload(path_base + "1.png"),preload(path_base + "2.png"),preload(path_base + "3.png")]
var input_locked := false

const MAX_ROCKS_PICKED = 3
var nearby_rocks: Array[Node] = []
var rocks_picked: int = 0

var throw_speed := 1_250
var aim_angle := deg_to_rad(20)
var min_angle := deg_to_rad(-90)
var max_angle := deg_to_rad(90)
var angle_speed := 0.5

var enemy_count := 0

func _ready() -> void:
	enemy_count = get_tree().get_nodes_in_group("enemy").size()
	#print(enemy_count)

func _physics_process(delta: float) -> void:
	if input_locked:
		velocity.x = 0
		move_and_slide()
		return
		
	var direction := Input.get_axis("move_left", "move_right")
	
	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()
	update_trajectory()

func _process(delta):
	set_sprite()
	if Input.is_action_pressed("aim_up"):
		aim_angle -= angle_speed * delta
		#print("aim angle: ", aim_angle)
	if Input.is_action_pressed("aim_down"):
		aim_angle += angle_speed * delta
		#print("aim angle: ", aim_angle)
	aim_angle = clamp(aim_angle, min_angle, max_angle)

func set_sprite():
	var i = max(MAX_ROCKS_PICKED,rocks_picked)
	$Sprite2D.texture = sprites[rocks_picked]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		#print("throw")
		throw_rock()
	if event.is_action_pressed("pickup"):
		#print("pickup")
		pickup_nearest_rock()
	if event.is_action_pressed("debug_print"):
		print("---DEBUG---")
		print("mouse pos: ",get_global_mouse_position())
		#print("nearby rocks: ",nearby_rocks)
		#print("rocks picked: " ,rocks_picked)

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
		if i % 5 == 0:
			points.append(pos)

	trajectory.points = points
	
# THROWING ROCKS
	
func throw_rock():
	if rocks_picked == 0:
		#print("No rocks to throw")
		return
	rocks_picked -= 1
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	var dir = Vector2.UP.rotated(aim_angle).normalized()
	rock.initiate_rock(global_position,throw_speed,dir,"player")
	
# HANDLING PICKUPS
func _on_pickup_area_area_entered(area: Area2D) -> void:
	#print("entered")
	if area.is_in_group("rocks"):
		nearby_rocks.append(area)

func _on_pickup_area_area_exited(area: Area2D) -> void:
	#print("exited")
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
	#print("Player took damage: ", amount)
	health -= amount
	if health <= 0:
		GM.death()
