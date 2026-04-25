extends RigidBody2D

var pickup_label_offset_x = -181
var pickup_label_offset_y = -85

var player_nearby = false
var player = null

var was_collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.top_level = true
	$Label.visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.global_position = global_position + Vector2(pickup_label_offset_x,pickup_label_offset_y)
	$Label.rotation = 0
	#print("collected",was_collected)
	

func _input(event: InputEvent) -> void:
	#print("pickup triggered in crown")
	if event.is_action_pressed("pickup") and player_nearby and not was_collected:
		was_collected = true
		$Label.visible = false
		get_tree().current_scene.disable_right_wall_and_camera_limits()
		GM.to_map()
		
func show_crown(pos : Vector2):
	global_position = pos
	#print("crown is here")

func _on_pickup_area_body_entered(body: Node2D) -> void:
	print("somebody entered")
	if body.is_in_group("player"):
		#print("player entered")
		player_nearby = true	
		$Label.visible = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	print("somebody exited")
	if body.is_in_group("player"):
		player_nearby = false
		$Label.visible = false
		#print("player exited")
