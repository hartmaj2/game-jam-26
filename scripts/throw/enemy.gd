extends CharacterBody2D

var debug = false

signal enemy_died

@export var speed: float = 300.0
@export var rock_scene: PackedScene
@export var crown_scene : PackedScene
@export var wall : StaticBody2D
@export var throw_speed: float = 1300.0
@export var health: int = 1

@onready var crushed = $Crushed
@onready var cry = $Cry

var direction: int = [-1, 1].pick_random() # Randomly choose left or right
var has_rock := false
var can_pick_up := true
var target_player: Node2D = null

var wall_x := 1050.0 # hotfix for wall collision, provisional
var wall_top_y := 400.0 # hotfix for wall collision, provisional
var wall_top = null

var is_active = false

@export var is_king = false
@export var is_harmless = false
const path_base = "res://assets/img/throw/stickman2"
const normal_texture = preload(path_base + ".png")
const king_texture = preload(path_base + "_king.png")

func _ready():
	var trigger_area = get_tree().current_scene.get_node("TriggerAreas/EnterThrowingFight")
	trigger_area.connect("body_entered", Callable(self, "_on_enter_throwing_fight_body_entered"))
	# print(GM.current_index)
	if GM.current_index == 1 or debug:
		setup_lava_timer()
	# print(is_harmless)
	if is_harmless:
		$Sprite2D.visible = false
		$CollisionShape2D.disabled = true
		$Sprite2D_Child.visible = true
		$CollisionShape2D_Child.disabled = false
	set_sprite()

func setup_lava_timer():
	#print("creating timer")
	var timer = Timer.new()
	timer.wait_time = randf_range(5,10)
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)

	timer.timeout.connect(_on_lava_timeout)

func _on_lava_timeout():
	if not is_active:
		return
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	throw_at_player(rock,true)

func _physics_process(_delta: float) -> void:
	if not is_active:
		velocity.x = 0.0
		$AnimationPlayer.play("idle")
		#$Sprite2D.animation = "idle"
		$Sprite2D_Child.animation = "idle"
		$Sprite2D.flip_h = true
		$Sprite2D_Child.flip_h = true
		return

	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()

	if is_on_wall():
		direction *= -1

	if is_active and velocity.x != 0:
		#$Sprite2D.animation = "left"
		$AnimationPlayer.play("left")
		$Sprite2D_Child.animation = "left"
		$Sprite2D.flip_h = direction < 0
		$Sprite2D_Child.flip_h = direction < 0


func setup_references():
	if target_player == null:
		target_player = get_tree().get_first_node_in_group("player")
	if wall_top == null:
		wall_top = get_tree().get_first_node_in_group("wall").get_node("EnemyWallTop")
		#print("wall top: ", wall_top.global_position)
		wall_x = wall_top.global_position.x
		wall_top_y = wall_top.global_position.y

func _process(_delta: float) -> void:
	setup_references()
	

func set_sprite():
	if is_king:
		$Crown.visible = true
	pass #TODO: add different sprites for king and normal, and for harmless as well

func find_throw_direction():
	var best_dir = Vector2.UP.rotated(deg_to_rad(-45))
	var best_dist = INF

	var g = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var dt = 1.0 / 60.0

	for angle in range(-60,-5, 5):
		var dir = Vector2.UP.rotated(deg_to_rad(angle))
		var vel = dir * throw_speed
		var pos = global_position
		var min_dist = INF

		# check wall collision
		if will_hit_wall(dir):
			#print("will hit wall with angle: ", angle)
			continue

		for i in range(180):
			vel += g * dt
			pos += vel * dt
						
			var dist = pos.distance_to(target_player.global_position)
			if dist < min_dist:
				min_dist = dist
		
		#print("angle: ", angle, " min dist: ", min_dist)
		if min_dist < best_dist:
			best_dist = min_dist
			best_dir = dir
			#print("new best angle: ", angle, " dist: ", min_dist)

	#print("best angle: ", rad_to_deg(best_dir.angle_to(Vector2.UP)))
	return best_dir

func will_hit_wall(dir):
	var g = ProjectSettings.get_setting("physics/2d/default_gravity")
	var v = dir.normalized() * throw_speed
	var vx = v.x
	if abs(vx) < 0.01:
		return false
	var t = (wall_x - global_position.x) / vx
	if t < 0:
		return false
	var y = global_position.y + v.y * t + 0.5 * g * t * t
	# breakpoint
	if y > wall_top_y:
		return true
	var pos = global_position
	var vel = dir * throw_speed
	var gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var dt = 1.0 / Engine.physics_ticks_per_second

	for i in range(30):
		vel += gravity * dt
		var next_pos = pos + vel * dt
		pos = next_pos

	return false

func throw_at_player(rock: Node2D, is_lava : bool = false):
	# var dir = (target_player.global_position - global_position).normalized()
	var dir = find_throw_direction()
	rock.initiate_rock(global_position, throw_speed, dir,"enemy",is_lava)
	has_rock = false
	await get_tree().create_timer(0.2).timeout
	can_pick_up = true

func die():
	enemy_died.emit()
	if is_harmless:
		cry.play()
		GM.death()
	elif is_king:
		crushed.play()
		call_deferred("drop_crown")
	else:
		crushed.play()
	queue_free()

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		die()

func drop_crown():
	var crown = crown_scene.instantiate()
	get_tree().current_scene.add_child(crown)
	crown.show_crown(global_position)

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if not can_pick_up or is_harmless:
		return

	if area.is_in_group("rocks") and not has_rock:
		var rock = area.get_parent()
		if rock.is_thrown or rock.was_thrown_recently:
			return
		has_rock = true
		can_pick_up = false
		throw_at_player(area.get_parent())


func _on_enter_throwing_fight_body_entered(_body: Node2D) -> void:
	await get_tree().create_timer(0.5).timeout
	is_active = true
