@tool

extends Area2D

@export var next_scene: String = ""
@export var player_spawn_position:= Vector2.ZERO
# TODO: Fix this. It doesn't make sense that we get the spawn point from a door that isn't in the next scene.
# it would be better to get the spawn point from the door you're supposedly walking through in the next scene. 
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(to_local(player_spawn_position), 2, Color.RED)

func _on_body_entered(body: Node2D) -> void:
	print("the body has entered")
	if body is Player:
		SceneManager.player_spawn_position = player_spawn_position
		print("%s" % player_spawn_position)
		get_tree().change_scene_to_file.call_deferred(next_scene)


func _on_body_exited(body: Node2D) -> void:
	print("the body has exited")
