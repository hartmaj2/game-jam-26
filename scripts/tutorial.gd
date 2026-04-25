extends Node2D
var def_off = Vector2(0, -340)

func _physics_process(delta: float) -> void:
	var offset = Vector2(0,0)
	var current_strength = GM.current_strength/4
	if current_strength > 0.0:
		offset = Vector2(
			randf_range(-current_strength, current_strength),
			randf_range(-current_strength, current_strength)
		)
	$Jumper/Camera2D.offset = offset+def_off
	GM.current_strength -=GM.fading*2*float(current_strength>0)


func _on_end_body_entered(body: Node2D) -> void:
	GM.to_cave()
