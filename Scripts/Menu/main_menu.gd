extends Control

const PLAYER = preload("res://Scenes/Player/player.tscn")
@onready var button_2: Button = $VBoxContainer/Button2

func _ready() -> void:
	var save_path = "res://Resources/Player/saved_player.tres"
	var saved_game = ResourceLoader.load(save_path) as SavedGame
	if saved_game.timestamp == 0:
		button_2.disabled = true
	GlobalScene.music.play()

func _on_new_game_pressed() -> void:
	GlobalScene.last_scene_name=get_tree().current_scene.name
	GlobalScene.player=PLAYER.instantiate()
	GlobalScene.is_new_game = true
	GlobalScene.change_scene("res://Scenes/Levels/game.tscn")

func _on_settings_pressed() -> void:
	GlobalScene.change_scene("res://Scenes/Menu/settings_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_load_game_pressed() -> void:
	GlobalScene.last_scene_name=get_tree().current_scene.name
	GlobalScene.player=PLAYER.instantiate()
	GlobalScene.is_new_game = false
	GlobalScene.change_scene("res://Scenes/Levels/game.tscn")
