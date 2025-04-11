extends CanvasLayer

class_name TransitionManager
signal transition_done

@onready var panel: Panel = $Panel
@onready var label: Label = $Label
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var color_rect: ColorRect = $ColorRect
@onready var music: AudioStreamPlayer = $Music
@onready var save_game_button: Button = $VBoxContainer/SaveGameButton

@export var transition_time = 1.0
const PLAYER = preload("res://Scenes/Player/player.tscn")
var next_scene_path: String
var last_scene_name: String
var is_transitioning = false
var player_spawn_position = null
var player: Node = null
var is_win: bool = false
var is_paused: bool = false
var is_new_game: bool
var taken_items: Array[String]
var original_normal_style: StyleBoxFlat = null
var original_hover_style: StyleBoxFlat = null

func _ready() -> void:
	color_rect.modulate.a =0
	color_rect.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	panel.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func fade_out():
	is_transitioning = true
	color_rect.modulate.a = 0
	color_rect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 1, transition_time)
	tween.finished.connect(on_fade_out_completed)

func on_fade_out_completed():
	get_tree().change_scene_to_file(next_scene_path)
	fade_in()

func fade_in():
	color_rect.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0, transition_time)
	tween.finished.connect(on_fade_in_finished)

func on_fade_in_finished():
	is_transitioning = false
	transition_done.emit()

func change_scene(next_scene_change: String):
	if is_transitioning:
		return
	self.next_scene_path = next_scene_change
	fade_out()

func toggle_pause():
	if is_paused:
		unpause_game()
	else:
		pause_game()

func pause_game():
	get_tree().paused = true
	is_paused = true
	label.show()
	v_box_container.show()
	#color_rect.modulate.a = 1

func _on_exit_to_main_menu():
	GlobalScene.change_scene("res://Scenes/Menu/main_menu.tscn")

func unpause_game():
	label.hide()
	v_box_container.hide()
	get_tree().paused = false
	is_paused = false
	#color_rect.modulate.a = 0
	if original_normal_style:
		save_game_button.add_theme_stylebox_override("normal", original_normal_style)
	if original_hover_style:
		save_game_button.add_theme_stylebox_override("hover", original_hover_style)

func _on_save_game_button_pressed() -> void:
	player.save_game()
	if original_normal_style == null:
		original_normal_style = save_game_button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	if original_hover_style == null:
		original_hover_style = save_game_button.get_theme_stylebox("hover").duplicate() as StyleBoxFlat

	# Change the button normal color to green
	var new_normal_style = original_normal_style.duplicate() as StyleBoxFlat
	new_normal_style.bg_color = Color.GREEN
	save_game_button.add_theme_stylebox_override("normal", new_normal_style)

	# Change the button hover color to dark green
	var new_hover_style = original_hover_style.duplicate() as StyleBoxFlat
	new_hover_style.bg_color = Color.DARK_GREEN
	save_game_button.add_theme_stylebox_override("hover", new_hover_style)


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
	v_box_container.hide()

func _on_quit_game_button_pressed() -> void:
	unpause_game()
	GlobalScene.change_scene("res://Scenes/Menu/main_menu.tscn")
