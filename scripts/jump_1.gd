extends Node2D

func _on_end_body_entered(_body: Node2D) -> void: GM.from_cave()

func _on_death_body_entered(_body: Node2D) -> void: GM.death()
