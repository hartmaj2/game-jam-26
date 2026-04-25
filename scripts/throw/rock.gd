extends RigidBody2D

var is_thrown := false
var thrown_by := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp = 0
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_thrown:
		#print("thrown by ",thrown_by)
	if linear_velocity.length() < 10:
		is_thrown = false
	pass
	

func initiate_rock(position : Vector2, speed : float, direction : Vector2, who : String):
	global_position = position
	linear_velocity = speed * direction.normalized()
	await get_tree().create_timer(0.2).timeout
	thrown_by = who
	is_thrown = true


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("floor"):
		is_thrown = false
	if not is_thrown:
		return
	#print("this rock was thrown by: ",thrown_by)
	if body.is_in_group("enemy"):
		is_thrown = false
		if thrown_by == "enemy":
			return
		body.take_damage(1)
	if body.is_in_group("player"):
		if thrown_by == "player":
			return
		is_thrown = false
		body.take_damage(1)
