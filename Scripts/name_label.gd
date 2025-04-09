extends Label

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() + Vector2(-10, -40)
