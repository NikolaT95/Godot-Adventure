extends Enemy
class_name EnemyBlue

var closest_friend: Enemy = null
const ENEMY_BLUE = preload("res://Scenes/enemy_blue.tscn")
func get_closest_enemy_red(max_distance: float):
	var closest_distance = max_distance

	for enemy in get_tree().get_nodes_in_group("enemy_red"):
		var dist = position.distance_to(enemy.position)
		if dist < closest_distance:
			closest_distance = dist
			closest_friend = enemy
	if closest_distance == max_distance:
		closest_friend = null

func on_died():
	super()
	game.queue_respawn(ENEMY_BLUE, initial_position, respawn_time, level)
