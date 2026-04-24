extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT



func _physics_process(delta: float) -> void:
	# Add the gravity.
	#print(delta)
	var floored = is_on_floor()
	if floored: coyote = COYOTE_INIT
	else:
		coyote -= delta*float((coyote>=0))
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote > 0:
		print(coyote)
		velocity.y = JUMP_VELOCITY
		coyote = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction: velocity.x = direction * SPEED
	else: velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
