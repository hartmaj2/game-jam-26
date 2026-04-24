extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GM.from_cave()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_end_body_entered(body: Node2D) -> void:
	print(body.name)
	GM.from_cave()
