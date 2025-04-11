extends Node2D

@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var player_spawn_position_start: Marker2D = $PlayerSpawnPositionStart

var player_scene = preload("res://Scenes/Player/player.tscn")
var player: Node = null
var respawn_queue = []

func _ready() -> void:
	player=GlobalScene.player
	add_child(player)
	GlobalScene.transition_done.connect(on_transition_done)
	if GlobalScene.is_transitioning:
		player.set_physics_process(false)
		player.set_process_input(false)
	if GlobalScene.last_scene_name != "MainMenu":
		player.position=player_spawn_position.position
	else:
		player.position=player_spawn_position_start.position
		if GlobalScene.is_new_game == false:
			player.load_game()
			for taken in GlobalScene.taken_items:
				var node = get_tree().root.get_node_or_null("Game/PickUpItems/" + taken)
				if node:
					node.queue_free()  # Removes the item from the tree
				else:
					print("Warning: Item node not found -> " + taken)

func on_transition_done():
	player.set_physics_process(true)
	player.set_process_input(true)

func queue_respawn(enemy_scene: PackedScene, enemy_position: Vector2, respawn_time: float, level: int):
	var timer = Timer.new()
	timer.wait_time = respawn_time
	timer.one_shot = true
	timer.timeout.connect(func():
		respawn_enemy(enemy_scene, enemy_position, level)
	)
	add_child(timer)
	timer.start()

func respawn_enemy(enemy_scene: PackedScene, enemy_position: Vector2, level: int):
	var new_enemy = enemy_scene.instantiate()
	new_enemy.level = level
	new_enemy.global_position = enemy_position
	get_tree().root.get_node_or_null("Game/Enemies/").add_child(new_enemy)
