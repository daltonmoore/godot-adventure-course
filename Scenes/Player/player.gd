extends CharacterBody2D
class_name Player

@export var push_strength: float = 10.0
@export_range(1, 150) var SPEED: int = 100

func _ready() -> void:
	if SceneManager.player_spawn_position != Vector2.ZERO:
		position = SceneManager.player_spawn_position

func _physics_process(delta: float) -> void:
	var move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_direction * SPEED
	
	move_player()
	
	push_blocks()
	
	move_and_slide()

func move_player() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.play("move_right")
	elif velocity.x < 0:
		$AnimatedSprite2D.play("move_left")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("move_down")
	elif velocity.y < 0:
		$AnimatedSprite2D.play("move_up")
	elif velocity == Vector2.ZERO:
		$AnimatedSprite2D.stop()

func push_blocks() -> void:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider_node: Node = collision.get_collider()
		if collider_node.is_in_group("pushable"):
			var collision_normal = collision.get_normal()
			collider_node.apply_central_force(-collision_normal * push_strength)
