extends TileMapLayer

func hide_secret_wall() -> void:
	visible = false
	collision_enabled = false

func show_secret_wall() -> void:
	visible = true
	collision_enabled = true
