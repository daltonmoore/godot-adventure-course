extends CharacterBody2D
class_name Player

@export var push_strength: float = 10.0
@export_range(1, 150) var SPEED: int = 100
@export var acceleration: float = 5.0
@export var knockback_strength: float = 200.0
@export var on_hit_color:= Color(50.0, 50.0, 50.0)


#region Debug Vars
var debug_moving_string: String = ""
var _debug_knockback_source: Node2D
var _debug_knockback_target: Node2D
#endregion

var is_attacking: bool = false
var last_move_direction
var can_interact:bool = false


func _ready() -> void:
	%SwordArea2D.monitoring = false
	if SceneManager.player_spawn_position != Vector2.ZERO:
		position = SceneManager.player_spawn_position


func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(input_direction * SPEED, acceleration)
	%TreasureLabel.text = str(SceneManager.opened_chests.size())
	if not is_attacking:
		move_player()
	else:
		velocity = Vector2.ZERO
	
	push_blocks()
	
	if Input.is_action_just_pressed("interact") and not can_interact:
		attack()
	
	move_and_slide()


func _draw() -> void:
	if not debug_mode:
		return
	
	if _debug_knockback_source != null or _debug_knockback_target != null:
		draw_line(to_local(_debug_knockback_source.global_position), _debug_knockback_target.velocity, Color.ORANGE)


func attack() -> void:
	$AttackSFX.play()
	$AttackDurationTimer.start()
	%Sword.visible = true
	%SwordArea2D.monitoring = true
	is_attacking = true
	# if last_move_direction is move_up, we'll get "up"
	var attack_anim = "attack_%s" % last_move_direction.get_slice("_", 1)
	$AnimatedSprite2D.play(attack_anim)
	$AnimationPlayer.play(attack_anim)


func die() -> void:
	if SceneManager.player_hp <= 0:
		SceneManager.player_hp = 3 # MAGIC NUMBERSSS?????
		get_tree().call_deferred("reload_current_scene")


func move_player() -> void:
	if debug_mode:
		var local_moving_debug_string = "moving velocity is %s" % str(velocity)
		if debug_moving_string != local_moving_debug_string:
			debug_moving_string = local_moving_debug_string
			print(debug_moving_string)
	
	if velocity.x > 0:
		$AnimatedSprite2D.play("move_right")
		$InteractArea.position = Vector2(8, 0)
	elif velocity.x < 0:
		$AnimatedSprite2D.play("move_left")
		$InteractArea.position = Vector2(-8, 0)
	elif velocity.y > 0:
		$AnimatedSprite2D.play("move_down")
		$InteractArea.position = Vector2(0, 8)
	elif velocity.y < 0:
		$AnimatedSprite2D.play("move_up")
		$InteractArea.position = Vector2(0, -8)
	elif velocity == Vector2.ZERO:
		$AnimatedSprite2D.stop()
	
	var player_animation : StringName = $AnimatedSprite2D.animation
	if player_animation.get_slice("_", 0) == "move":
		last_move_direction = player_animation


func push_blocks() -> void:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider_node: Node = collision.get_collider()
		if collider_node.is_in_group("pushable"):
			var collision_normal = collision.get_normal()
			collider_node.apply_central_force(-collision_normal * push_strength)


func update_hp_bar() -> void:
	%HealthBar.play("%s_hp" % SceneManager.player_hp)


func _flash() -> void:
	modulate = on_hit_color
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE # Setting it to white is the original color


func _knockback(source, target) -> void:
	var distance_to_target: Vector2 = target.global_position - source.global_position
	var knockback_direction: Vector2 = distance_to_target.normalized()
	
	target.velocity += knockback_direction * knockback_strength
	_debug_knockback_source = source
	_debug_knockback_target = target
	queue_redraw()


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = true
		can_interact = true


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = false
		can_interact = false


func _on_hitbox_area_2d_body_entered(body: Node2D) -> void:
	SceneManager.player_hp -= 1
	update_hp_bar()
	$HitSFX.play()
	die()
	_knockback(body, self)
	_flash()


func _on_sword_area_2d_body_entered(body: Node2D) -> void:
	_knockback(self, body)
	body.take_damage()


func _on_attack_duration_timer_timeout() -> void:
	%Sword.visible = false
	%SwordArea2D.monitoring = false
	is_attacking = false
	$AnimatedSprite2D.play(last_move_direction)
