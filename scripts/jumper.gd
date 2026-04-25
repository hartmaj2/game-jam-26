extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT
@onready var sfx = $AudioStreamPlayer
var hop = preload("res://assets/sounds/sfx/hop.wav")
var impact = preload("res://assets/sounds/sfx/impact1.mp3")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#print(delta)
	var floored = is_on_floor()
	if coyote < 0 and floored:
		sfx.stream = impact
		sfx.play()
	if floored: coyote = COYOTE_INIT
	else:
		coyote -= delta*float((coyote>=0))
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote > 0 and GM.controllable:
		velocity.y = JUMP_VELOCITY
		coyote = 0
		sfx.stream = hop
		sfx.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and GM.controllable:
		velocity.x = direction * SPEED
		if direction > 0:
			$Sprite2D.animation = "left"
			$Sprite2D.flip_h = true
		elif direction < 0:
			$Sprite2D.animation = "left"
			$Sprite2D.flip_h = false
	else:
		$Sprite2D.animation = "idle"
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not floored: $Sprite2D.animation = "jump"

	move_and_slide()
