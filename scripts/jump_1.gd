extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_end_body_entered(body: Node2D) -> void: GM.to_map()

func _on_death_body_entered(body: Node2D) -> void: GM.death()
