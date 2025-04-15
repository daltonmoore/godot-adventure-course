@tool
class_name Switch

extends StaticBody2D

signal switch_activated(switch: Switch)
signal switch_deactivated(switch: Switch)

@export var part_of_solution: bool = false
@export var debug_position: Vector2 = Vector2.UP * 15

var debug: bool = false
var can_interact: bool = false
var is_activated: bool = false

func _draw() -> void:
	if !debug and !Engine.is_editor_hint():
		return
	
	if part_of_solution:
		draw_circle(debug_position,3,Color.GREEN)
	else:
		draw_circle(debug_position,3,Color.RED)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	
	if Input.is_action_just_pressed("interact") and can_interact:
		if is_activated:
			$AnimatedSprite2D.play("deactivated")
			$AudioStreamPlayer2D.pitch_scale = 0.75
			switch_deactivated.emit(self)
			is_activated = false
		else:
			$AnimatedSprite2D.play("activated")
			$AudioStreamPlayer2D.pitch_scale = 1.0
			switch_activated.emit(self)
			is_activated = true
		
		$AudioStreamPlayer2D.play()
		
