extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -800.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT
@onready var hop = $Hop
@onready var impact = $Impact
var falling = 0
var drop = false

func _physics_process(delta: float) -> void:
	var floored = is_on_floor()
	if coyote < 0 and floored:
		impact.play()
		GM.trigger_shake(falling+falling*float(drop), max(float(drop),0.5))
		drop = false
		$LeftParty.emitting = true
		$RightParty.emitting = true
	if floored: coyote = COYOTE_INIT
	else:
		coyote -= delta*float((coyote>=0))
		var decay = get_gravity() * delta
		velocity +=  decay+1.2*float(drop)*decay
		falling = velocity.y/100
		

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and coyote > 0 and GM.controllable:
		velocity.y = JUMP_VELOCITY
		coyote = 0
		hop.play() 

	var direction := Input.get_axis("move_left", "move_right")
	if direction and GM.controllable:
		velocity.x = direction * SPEED
		if direction > 0:
			$Sprite2D.animation = "left"
			$Sprite2D.flip_h = false
		elif direction < 0:
			$Sprite2D.animation = "left"
			$Sprite2D.flip_h = true
	else:
		$Sprite2D.animation = "idle"
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not floored:
		$Sprite2D.animation = "jump"
		if Input.is_action_pressed("aim_down"):
			velocity+=get_gravity()*3*delta
			drop = true
			
			velocity.y = max(velocity.y, 0)
	move_and_slide()


func _on_end_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
