extends Node2D

func _physics_process(delta: float) -> void:
	var offset = Vector2(0,0)
	var current_strength = GM.current_strength
	if GM.current_strength > 0.0:
		offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength))
	$Jumper/Camera2D.offset = offset
	GM.current_strength -=GM.fading*float(current_strength>0)

func _on_end_body_entered(_body: Node2D) -> void: ending()

func _on_death_body_entered(_body: Node2D) -> void: GM.death(3)

func ending():
	GM.from_cave()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_level"):
		ending()
