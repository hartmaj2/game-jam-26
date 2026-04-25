extends CharacterBody2D

const JUMP_VELOCITY = -800.0
const GRAVITY = 25
@onready var hop = $Hop
@onready var impact = $Impact
var just_jumped = false

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

var wall = null

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.is_harmless:
			continue
		enemy_count += 1
	for enemy in enemies:
		if not enemy.is_connected("enemy_died", Callable(self, "_on_enemy_died")):
			#print("connected to enemy signal")
			enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _physics_process(delta: float) -> void:
	if input_locked:
		velocity.x = 0
		move_and_slide()
		return

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	velocity.y += GRAVITY
	move_and_slide()
	update_trajectory()

	var floored = is_on_floor()
	#print("floored: ", floored, " just_jumped: ", just_jumped)
	if floored and just_jumped:
		impact.play()
		GM.trigger_shake(10,0.5)
		just_jumped = false
		# $LeftParty.emitting = true
		# $RightParty.emitting = true

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and GM.controllable:
		just_jumped = true
		velocity.y = JUMP_VELOCITY
		hop.play()


func _process(delta):
	set_sprite()
	setup_references()
	if Input.is_action_pressed("aim_up"):
		if rocks_picked != 0:
			aim_angle -= angle_speed * delta
		#print("aim angle: ", aim_angle)
	if Input.is_action_pressed("aim_down"):
		if rocks_picked != 0:
			aim_angle += angle_speed * delta
		#print("aim angle: ", aim_angle)
	aim_angle = clamp(aim_angle, min_angle, max_angle)
	
func setup_references():
	if wall == null:
		wall = get_tree().get_first_node_in_group("wall")

func set_sprite():
	var i = min(MAX_ROCKS_PICKED,rocks_picked)
	$Sprite2D.texture = sprites[i]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		#print("throw")
		throw_rock(aim_angle)
	if event.is_action_pressed("pickup"):
		#print("pickup")
		pickup_nearest_rock()
	if event.is_action_pressed("debug_print"):
		print("---DEBUG---")
		print("mouse pos: ",get_global_mouse_position())
		kill_all_enemies()
		#print("nearby rocks: ",nearby_rocks)
		#print("rocks picked: " ,rocks_picked) 

func get_rid_of_rocks():
	while rocks_picked > 0:
		var angle = deg_to_rad(randi_range(-60,60))
		throw_rock(angle)
		await get_tree().create_timer(0.2).timeout

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
		if i % 1 == 0:
			points.append(pos)
		if pos.y > 1000:
			#points.append(Vector2(pos.x,1000))
			break

	trajectory.points = points
	
# THROWING ROCKS
	
func throw_rock(angle):
	if rocks_picked == 0:
		#print("No rocks to throw")
		return
	rocks_picked -= 1
	if rocks_picked == 0:
		trajectory.visible = false
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	var dir = Vector2.UP.rotated(angle).normalized()
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

func kill_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.is_harmless:
			continue
		enemy.die()

func pickup_nearest_rock() -> void:
	if nearby_rocks.is_empty():
		return

	if enemy_count == 0:
		return

	var rock_area := nearby_rocks[0]
	var rock = rock_area.get_parent()
	
	if rock.is_thrown or rock.was_thrown_recently:
		return
	
	nearby_rocks.erase(rock_area)

	rock.queue_free()
	rocks_picked += 1
	trajectory.visible = true

func take_damage(amount: int = 1):
	#print("Player took damage: ", amount)
	health -= amount
	if health <= 0:
		GM.death()

func _on_enemy_died():
	print("enemy died", enemy_count - 1, " remaining")
	enemy_count -= 1
	if enemy_count == 0:
		hide_label()
		get_rid_of_rocks()
		wall.open_tower()
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			enemy.is_active = false

func show_label():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() != 0:
		get_tree().current_scene.get_node("PickRockLabel").visible = true

func hide_label():
	if nearby_rocks.size() == 0 or enemy_count == 0:
		get_tree().current_scene.get_node("PickRockLabel").visible = false
