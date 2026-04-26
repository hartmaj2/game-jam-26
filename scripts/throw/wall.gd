extends StaticBody2D


var texture_closed = preload("res://assets/img/wall.png")
var texture_open = preload("res://assets/img/wall_open.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = texture_closed
	z_index += 10
	pass # Replace with function body.
	
func open_tower():
	#print("tower is open")
	#$Sprite2D.texture = texture_open
	var tween := create_tween()
	tween.tween_property($Gate, "rotation",deg_to_rad(-90), 2.5)
	$CollisionShape2D.set_deferred("disabled", true)
