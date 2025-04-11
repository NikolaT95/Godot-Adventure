extends Enemy

signal died

const ENEMY_YELLOW = preload("res://Scenes/Enemy/enemy_yellow.tscn")
func is_enemy_nearby(radius: float) -> bool:
	var player_position = global_position
	for enemy in get_tree().get_nodes_in_group("enemy_blue"):
		if enemy.global_position.distance_to(player_position) < radius:
			return true
	return false

func on_died():
	super()
	died.emit()
	game.queue_respawn(ENEMY_YELLOW, initial_position, respawn_time, level)
