extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func initiate_rock(position : Vector2, speed : float, direction : Vector2):
	global_position = position
	linear_velocity = speed * direction.normalized()
	
