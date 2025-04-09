extends Area2D

@onready var player_spawn_position: Marker2D = $"../PlayerSpawnPosition"

func _on_body_entered(_body: Node2D) -> void:
	GlobalScene.last_scene_name = get_tree().current_scene.name
	var player = get_node("/root/Game/Player")
	var player_camera = player.get_node("Camera2D")
	var temp_camera = Camera2D.new()
	temp_camera.global_position = Vector2(20,8)
	temp_camera.zoom = player_camera.zoom
	add_child(temp_camera)
	temp_camera.make_current()
	player.get_parent().remove_child(player)
	GlobalScene.change_scene("res://Scenes/boss_scene.tscn")
