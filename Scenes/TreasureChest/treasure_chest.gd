extends StaticBody2D

@export var chest_id: int = 0

var can_interact: bool = false
var is_open: bool = false

func _ready() -> void:
	print("I am chest %s with chest_id %s" % [name, chest_id])
	if SceneManager.opened_chests.has(chest_id):
		is_open = true
		$AnimatedSprite2D.play("open")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		if !is_open:
			open_chest()

func open_chest() -> void:
	is_open = true
	$AnimatedSprite2D.play("open")
	$AudioStreamPlayer2D.pitch_scale = randf_range(.5, 1.0)
	$AudioStreamPlayer2D.play()
	$Treasure.visible = true
	$Timer.start()
	SceneManager.add_opened_chest(chest_id)


func _on_timer_timeout() -> void:
	$Treasure.visible = false
