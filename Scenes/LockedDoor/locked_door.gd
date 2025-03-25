extends StaticBody2D

@export var presses_required: int = 1

var pressed_count: int = 0

func _on_puzzle_button_pressed() -> void:
	pressed_count += 1
	if pressed_count == presses_required:
		visible = false
		$CollisionShape2D.set_deferred("disabled", true)


func _on_puzzle_button_unpressed() -> void:
	pressed_count -= 1
	if pressed_count < presses_required:
		visible = true
		$CollisionShape2D.set_deferred("disabled", false)
