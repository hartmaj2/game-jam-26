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


func _on_end_body_entered(_body: Node2D) -> void: GM.from_cave()

func _on_death_body_entered(_body: Node2D) -> void: GM.death()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("skibidi")
