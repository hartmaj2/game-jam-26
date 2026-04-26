extends CharacterBody2D


const MAX_SPEED = 500.0
var speed = MAX_SPEED
const JUMP_VELOCITY = -900.0
const COYOTE_INIT = 0.2
var coyote = COYOTE_INIT
@onready var hop = $Hop
@onready var impact = $Impact
@onready var walk = $Walk
var falling = 0
var drop = false

var in_water = false

func _physics_process(delta: float) -> void:
	var floored = is_on_floor()
	var is_jumping = Input.is_action_pressed("ui_accept")
	var is_dropping = Input.is_action_pressed("aim_down")
	var direction := Input.get_axis("move_left", "move_right")
	if floored:
		if coyote < 0:
			impact.play()
			GM.trigger_shake(falling+falling*float(drop), max(float(drop)*1.5,0.5))
			drop = false
			$LeftParty.emitting = true
			$RightParty.emitting = true
			coyote=COYOTE_INIT
			# staring idle
			$Sprite2D.animation = "idle"
		elif GM.controllable:
			if is_jumping and not is_dropping:
				velocity.y = JUMP_VELOCITY
				coyote = 0
				hop.play() 
				walk.stop()
				#starting jump animation
				$Sprite2D.animation = "jump"
			
			elif direction != 0:
				velocity.x = direction * speed
				$Sprite2D.animation = "left"
				$Sprite2D.flip_h = direction < 0
				if not walk.playing:
					walk.play()
			else:
				$Sprite2D.animation = "idle"
				velocity.x = 0
				#velocity.x = move_toward(velocity.x, 0, speed)
	else:
		if GM.controllable:
			if coyote > 0 and is_jumping and not is_dropping:
				print(is_dropping)
				velocity.y = JUMP_VELOCITY
				coyote = 0
				hop.play() 
				walk.stop()
				#starting jumping animation
				$Sprite2D.animation = "jump"
			if is_dropping and not is_jumping:
				velocity+=get_gravity()*3*delta
				drop = true
				velocity.y = max(velocity.y, 0)
				#falling animation
			#if direction != 0:
			velocity.x = direction * speed
			$Sprite2D.flip_h = direction < 0
			
		coyote -= delta*float((coyote>=0))
		var decay = get_gravity() * delta*1.2
		velocity +=  decay+1.2*float(drop)*decay
		falling = velocity.y/100
		
				
		
	#if coyote < 0 and floored:
		#impact.play()
		#GM.trigger_shake(falling+falling*float(drop), max(float(drop),0.5))
		#drop = false
		#$LeftParty.emitting = true
		#$RightParty.emitting = true
	#if floored: coyote = COYOTE_INIT
	#else:
		#coyote -= delta*float((coyote>=0))
		#var decay = get_gravity() * delta
		#velocity +=  decay+1.2*float(drop)*decay
		#falling = velocity.y/100
		#
#
	## Handle jump.
	#if Input.is_action_pressed("ui_accept") and coyote > 0 and GM.controllable:
		#velocity.y = JUMP_VELOCITY
		#coyote = 0
		#hop.play() 
		#walk.stop()
#
	#var direction := Input.get_axis("move_left", "move_right")
	#if direction and GM.controllable:
		#velocity.x = direction * speed
		#if direction!= 0:
			#$Sprite2D.animation = "left"
			#$Sprite2D.flip_h = direction < 0
			#if not walk.playing:
				#print("play")
				#walk.play()
	#else:
		#$Sprite2D.animation = "idle"
		#velocity.x = move_toward(velocity.x, 0, speed)
	#if not floored:
		#$Sprite2D.animation = "jump"
		#if Input.is_action_pressed("aim_down") and not Input.is_action_pressed("ui_accept"):
			#velocity+=get_gravity()*3*delta
			#drop = true
			#velocity.y = max(velocity.y, 0)
	move_and_slide()
