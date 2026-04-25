extends RigidBody2D

var texture_normal = preload("res://assets/img/throw/stone.png")
var texture_lava = preload("res://assets/img/throw/stone_lava.png")

var is_lava := false
var is_thrown := false
var was_thrown_recently := false
var thrown_by := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp = 0
	linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	pass # Replace with function body.

func set_mode():
	if is_lava:
		$Sprite2D.texture = texture_lava
	else:
		$Sprite2D.texture = texture_normal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	set_mode()
	if thrown_by == "enemy":
		set_collision_layer_value(3, false)
	if is_thrown:
		pass
		#print("thrown by ",thrown_by)
	if linear_velocity.length() < 10:
		is_thrown = false
	pass
	

func initiate_rock(pos : Vector2, speed : float, direction : Vector2, who : String, lava : bool = false):
	global_position = pos
	linear_velocity = speed * direction.normalized()
	#await get_tree().create_timer(0.2).timeout HERE TO AVOID KILLING YOURSELF
	is_lava = lava
	thrown_by = who
	is_thrown = true
	was_thrown_recently = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	#print("somebody exited")
	if body.is_in_group("player"):
		get_tree().get_first_node_in_group("player").hide_label()


func damage_body_from_group(body, group : String) -> bool:
	if body.is_in_group(group):
		if thrown_by == group:
			return true
		is_thrown = false
		linear_velocity = Vector2(0,0)
		body.take_damage(1)
		GM.trigger_shake(10,0.5)
		await get_tree().create_timer(0.5).timeout
		was_thrown_recently = false
		return true
	return false
	

func _on_pickup_area_body_entered(body: Node2D) -> void:
	# check if should show label
	if body.is_in_group("player") and not is_thrown and not was_thrown_recently:
		get_tree().get_first_node_in_group("player").show_label()
	
	if body.is_in_group("floor"):
		if is_lava:
			await get_tree().create_timer(0.5).timeout
			queue_free()
			return
		if is_thrown:
			GM.trigger_shake(10,0.5)
		is_thrown = false
		await get_tree().create_timer(0.5).timeout
		was_thrown_recently = false

	if not is_thrown:
		return
	#print("this rock was thrown by: ",thrown_by)
	if await damage_body_from_group(body,"enemy"):
		return
	if await damage_body_from_group(body,"player"):
		return
