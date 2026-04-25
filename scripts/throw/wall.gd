extends StaticBody2D


var texture_closed = preload("res://assets/img/throw/tower.png")
var texture_open = preload("res://assets/img/throw/tower_open.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = texture_closed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_tower():
	print("tower is open")
	$Sprite2D.texture = texture_open
	$CollisionShape2D.set_deferred("disabled", true)
