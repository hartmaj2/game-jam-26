extends CharacterBody2D

@export var speed: float = 200.0
@export var rock_scene: PackedScene
@export var throw_speed: float = 1200.0
@export var health: int = 1


var direction: int = [-1, 1].pick_random() # Randomly choose left or right
var has_rock := false
var can_pick_up := true
var target_player: Node2D = null

var wall_x := 1050.0 # hotfix for wall collision, provisional
var wall_top_y := 400.0 # hotfix for wall collision, provisional

func _ready():
	target_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:	
	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()

	if is_on_wall():
		direction *= -1

# func _draw():
# 	var width = 80
# 	var height = 10

# 	var top_left_world = Vector2(wall_x - width / 2, wall_top_y)
# 	var top_left = to_local(top_left_world)

# 	draw_rect(Rect2(top_left, Vector2(width, height)), Color.DARK_GRAY)

# func _process(delta):
# 	queue_redraw()

func find_throw_direction():
	var best_dir = Vector2(0, -1)
	var best_dist = INF

	var g = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var dt = 1.0 / 60.0

	for angle in range(-60, 60, 5):  
		var dir = Vector2.UP.rotated(deg_to_rad(angle))
		var vel = dir * throw_speed
		var pos = global_position

		# check wall collision
		if will_hit_wall(dir):
			print("will hit wall with angle: ", angle)
			continue

		for i in range(180):
			vel += g * dt
			pos += vel * dt

			var dist = pos.distance_to(target_player.global_position)
			if dist < best_dist:
				best_dist = dist
				best_dir = dir

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

func throw_at_player(rock: Node2D):
	# var dir = (target_player.global_position - global_position).normalized()
	var dir = find_throw_direction()
	rock.initiate_rock(global_position, throw_speed, dir)
	has_rock = false
	await get_tree().create_timer(0.2).timeout
	can_pick_up = true

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		queue_free()


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if not can_pick_up:
		return

	if area.is_in_group("rocks") and not has_rock:
		has_rock = true
		can_pick_up = false
		throw_at_player(area.get_parent())
