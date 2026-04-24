extends CharacterBody2D

@export var speed: float = 300.0
@export var rock_scene: PackedScene

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	velocity.x = direction * speed
	velocity.y = 0.0  # no vertical movement
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		throw_rock()

func throw_rock():
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	rock.initiate_rock(global_position,1000,Vector2(1,-1))
	
