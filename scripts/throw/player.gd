extends CharacterBody2D

@export var speed: float = 300.0
@export var rock_scene: PackedScene

@onready var pickup_area: Area2D = $PickupArea

var nearby_rocks: Array[Node] = []
var rocks_picked: int = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()

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
	
# THROWING ROCKS
	
func throw_rock():
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	rock.initiate_rock(global_position,1000,Vector2(1,-1))
	
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
