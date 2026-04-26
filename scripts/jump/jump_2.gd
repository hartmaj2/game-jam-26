extends Node2D


func _on_end_body_entered(body: Node2D) -> void:
	GM.from_cave()
