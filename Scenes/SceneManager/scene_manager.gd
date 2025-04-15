@tool

extends Node2D
var player_spawn_position:= Vector2.ZERO
var opened_chests: Array[int]
var next_chest_id: int = 0
var player_hp: int = 3

func get_next_chest_id() -> int:
	next_chest_id += 1
	return next_chest_id

func add_opened_chest(id: int) -> void:
	if opened_chests.has(id):
		printerr("opened chests already has id: %s" % id)
	else:
		opened_chests.append(id)
