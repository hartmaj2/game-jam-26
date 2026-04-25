extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	var tw = get_tree().create_tween()
	#tw.set_parallel(true)
	tw.tween_property($Camera2D,"position",Vector2(960, 1080+540), 2)
	tw.tween_property($Camera2D,"zoom",Vector2(2,2), 3)
	
