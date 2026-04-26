extends RigidBody2D

var texture_normal = preload("res://assets/img/throw/stone.PNG")
var texture_lava = preload("res://assets/img/throw/stone_lava_small.png")

var speed_threshold = 500
@onready var throw = $Throw
@onready var impact = $Impact
@onready var crushed = $Crushed
@onready var cry = $Cry

@export var thrown_by := ""
var is_thrown := false
var is_lava := false
var was_thrown_recently := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp = 0
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	pass # Replace with function body.

func set_mode():
	if is_lava:
		$Sprite2D.texture = texture_lava
		$Sprite2D.scale = Vector2(0.5,0.5)
	else:
		$Sprite2D.texture = texture_normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	set_mode()
	if thrown_by == "enemy":
		set_collision_layer_value(3,false)
		set_collision_layer_value(5,true)
		set_collision_mask_value(5,true)
		#set_collision_mask_value(3,false)
	if thrown_by == "special":
		#set_collision_layer_value(3,false)
		set_collision_mask_value(5,true)
	if is_thrown:
		pass
		#print("thrown by ",thrown_by)
	#print("lin vel y: ",linear_velocity.y)
	
	if abs(linear_velocity.y) < speed_threshold:
		is_thrown = false
	else:
		is_thrown = true
	

func initiate_rock(pos : Vector2, speed : float, direction : Vector2, who : String, lava : bool = false):
	throw.play()
	global_position = pos
	linear_velocity = speed * direction.normalized()
	#await get_tree().create_timer(0.2).timeout HERE TO AVOID KILLING YOURSELF
	is_lava = lava
	thrown_by = who
	is_thrown = true
	was_thrown_recently = true
	rotation = randf_range(0,PI*2)

func _on_pickup_area_body_exited(body: Node2D) -> void:
	#print("somebody exited")
	if body.is_in_group("player"):
		GM.trigger_handle_labels.emit()
		#get_tree().get_first_node_in_group("player").handle_labels()


func damage_body_from_group(body, group : String) -> bool:
	if body.is_in_group(group):
		if thrown_by == group:
			return true
		is_thrown = false
		#linear_velocity = Vector2(0,0) # stop rock on enemy hit
		body.take_damage(1)
		GM.trigger_shake(10,0.5)
		await get_tree().create_timer(0.5).timeout
		was_thrown_recently = false
		return true
	return false
	

func _on_pickup_area_body_entered(body: Node2D) -> void:
	# check if should show label
	if body.is_in_group("player") and not is_thrown and not was_thrown_recently:
		#get_tree().get_first_node_in_group("player").handle_labels()
		GM.trigger_handle_labels.emit()
	
	if body.is_in_group("floor"):
		if is_lava:
			queue_free()
			return
		if is_thrown:
			GM.trigger_shake(10,0.5)
			impact.play()
		is_thrown = false
		await get_tree().create_timer(0.5).timeout
		was_thrown_recently = false

	if not is_thrown:
		return

	if body.is_in_group("enemy") and thrown_by == "player":
		if body.is_harmless:
			cry.play()
		else:
			crushed.play()

	#print("this rock was thrown by: ",thrown_by)
	if await damage_body_from_group(body,"enemy"):	
		return
	if await damage_body_from_group(body,"player"):
		return
