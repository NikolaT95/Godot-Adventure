extends Control

@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)
@onready var window_mode =$PanelContainer2/VBoxContainer2/WindowMode as OptionButton
@onready var resolutin=$PanelContainer2/VBoxContainer2/Resolutions as OptionButton
const WINDOW_MODE_ARRAY: Array[String]=[
	"Window mode",
	"Borderless window",
	"Full-screen",
]

const RESOLUTION_DICTIONARY: Dictionary={
	"1152x648": Vector2i(1152,648),
	"1280x720": Vector2i(1280,720),
	"1366x768": Vector2i(1366,768),
}

func _ready() -> void:
	var volume = $PanelContainer/VBoxContainer/Volume
	volume.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	add_window_mode_items()
	add_resolution_items()

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))

func add_resolution_items()->void:
	for resolution_size in RESOLUTION_DICTIONARY:
		resolutin.add_item(resolution_size)

func _on_resolutions_item_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])

func add_window_mode_items()->void:
	for wm in WINDOW_MODE_ARRAY:
		window_mode.add_item(wm)

func _on_window_mode_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

func _on_button_pressed() -> void:
	GlobalScene.change_scene("res://Scenes/main_menu.tscn")
