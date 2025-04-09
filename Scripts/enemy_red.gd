extends Enemy

class_name EnemyRed

const ENEMY_RED = preload("res://Scenes/enemy_red.tscn")

func on_died():
	super()
	game.queue_respawn(ENEMY_RED, initial_position, respawn_time, level)
