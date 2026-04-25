extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT
@onready var sfx = $AudioStreamPlayer
var hop = preload("res://assets/sounds/sfx/hop.wav")
var impact = preload("res://assets/sounds/sfx/impact1.mp3")


@export var fade_speed: float = 5.0

# The current strength of the shake
var current_strength: float = 0.0

func _process(delta: float) -> void:
	# If there is active shake, apply it and fade it out
	var offset = Vector2(0,0)
	if current_strength > 0.0:
		offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	$Camera2D.offset = offset
	current_strength -=0.5

# Call this function to trigger a shake!
func apply_shake(strength: float = 15.0) -> void:
	current_strength = strength


func _physics_process(delta: float) -> void:
	var floored = is_on_floor()
	if coyote < 0 and floored:
		sfx.stream = impact
		sfx.play()
		apply_shake()
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
