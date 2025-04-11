extends Node

@onready var player_spawn_place: Marker2D = $PlayerSpawnPlace
@onready var enemy: CharacterBody2D = $Enemies/Enemy

const PLAYER = preload("res://Scenes/Player/player.tscn")

func _ready() -> void:
	GlobalScene.transition_done.connect(on_transition_done)
	var player = GlobalScene.player
	player.set_physics_process(false)
	player.set_process_input(false)
	self.add_child(player)
	player.position=player_spawn_place.position
	enemy.died.connect(player.player_won)

func on_transition_done():
	$Player.set_physics_process(true)
	$Player.set_process_input(true)

func _on_exit_body_entered(_body: Node2D) -> void:
	GlobalScene.last_scene_name= get_tree().current_scene.name
	var player = get_node("/root/BossScene/Player")
	var player_camera = player.get_node("Camera2D")
	var temp_camera = Camera2D.new()
	temp_camera.global_position = player_spawn_place.position
	temp_camera.zoom = player_camera.zoom
	add_child(temp_camera)
	temp_camera.make_current()
	player.get_parent().remove_child(player)
	GlobalScene.change_scene("res://Scenes/game.tscn")

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
	get_tree().root.get_node_or_null("BossScene/Enemies/").add_child(new_enemy)
