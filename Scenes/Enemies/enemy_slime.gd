extends CharacterBody2D

@export var speed: int = 30
@export var acceleration: float = 5.0
@export var health: int = 2
@export var on_hit_color:= Color(50.0, 0.0, 0.0)

var target: Node2D


func _ready() -> void:
	if not debug_mode:
		$PreferHorizontalLabel.visible = false
		$PreferHorizontalValue.visible = false


func _draw() -> void:
	if debug_mode:
		draw_line(Vector2.ZERO, velocity, Color.RED)


func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	
	chase_target()
	move_and_slide()
	animate()


func chase_target() -> void:
	if target == null:
		return
	
	var distance_to_player: Vector2
	distance_to_player = target.global_position - global_position
	var dir_normal: Vector2 = distance_to_player.normalized()
	velocity = velocity.move_toward(dir_normal * speed, acceleration)
	
	queue_redraw()


func animate() -> void:
	var normalized_velocity = velocity.normalized()
	var prefer_horizontal = (
			abs(normalized_velocity.x) > abs(normalized_velocity.y))
	$PreferHorizontalValue.text = str(prefer_horizontal)
	if prefer_horizontal:
		if normalized_velocity.x > 0: # Moving right
			$AnimatedSprite2D.play("move_right")
		elif normalized_velocity.x < 0: # Moving left
			$AnimatedSprite2D.play("move_left")
	else: 
		if normalized_velocity.y > 0: # Moving down
			$AnimatedSprite2D.play("move_down")
		elif normalized_velocity.y < 0: # Moving up
			$AnimatedSprite2D.play("move_up")


func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func take_damage() -> void:
	$DamageSFX.play()
	health -= 1
	if health <= 0:
		die()
	modulate = on_hit_color
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE
	

func die() -> void:
	$GPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1).timeout
	queue_free()
