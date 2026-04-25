extends Camera2D

var target_position: Vector2
var transitioning := false
var transition_speed := 6.0

func _ready():
	target_position = global_position


func set_target(pos: Vector2):
	target_position = pos
	transitioning = true


func _process(delta):
	if transitioning:
		global_position = global_position.lerp(target_position, 1.0 - exp(-transition_speed * delta))

		if global_position.distance_to(target_position) < 1.0:
			global_position = target_position
			transitioning = false
			