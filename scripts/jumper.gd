extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT
@onready var hop = $Hop
@onready var impact = $Impact
var fading: float = 0.5
var current_strength: float = 0.0


# Call this function to trigger a shake!
func trigger_shake(strength: float = 15.0) -> void:
	current_strength = strength
	
func apply_shake():
	var offset = Vector2(0,0)
	if current_strength > 0.0:
		offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	$Camera2D.offset = offset
	current_strength -=fading*float(current_strength>0)


func _physics_process(delta: float) -> void:
	var floored = is_on_floor()
	if coyote <= 0 and floored:
		impact.play()
		trigger_shake(-15*coyote)
	if floored: coyote = COYOTE_INIT
	else:
		coyote -= delta*float((coyote>=-5))
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and coyote > 0 and GM.controllable:
		velocity.y = JUMP_VELOCITY
		coyote = 0
		hop.play() 
		#current_strength /= 2

	var direction := Input.get_axis("move_left", "move_right")
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
	apply_shake()
	move_and_slide()
