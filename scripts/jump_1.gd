extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#scroll_offset = $Jumper/Camera2D.get_screen_center_position() * (Vector2.ONE - scroll_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_end_body_entered(body: Node2D) -> void: GM.from_cave()

func _on_death_body_entered(body: Node2D) -> void: GM.death()
