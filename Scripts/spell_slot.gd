extends VBoxContainer

class_name SpellSlot

@export var index: int
@export var single_button_press=false
@export var starting_texture: Texture
@export var start_label: String
@onready var texture_rect: TextureRect = %TextureRect
@onready var on_click_button: Button = $NinePatchRect/OnClickButton
@onready var name_label: Label = $NameLabel
@onready var on_screen_ui: InventoryUI = $"../.."
@onready var color_rect: ColorRect = $NinePatchRect/ColorRect
@onready var v_box_container: VBoxContainer = $NinePatchRect/VBoxContainer
@onready var damage_label: Label = $NinePatchRect/VBoxContainer/DamageLabel
@onready var cooldown_label: Label = $NinePatchRect/VBoxContainer/CooldownLabel
@onready var mana_label: Label = $NinePatchRect/VBoxContainer/ManaLabel

func _ready() -> void:
	texture_rect.texture = starting_texture
	name_label.text = start_label
	on_click_button.disabled =! single_button_press
	on_click_button.visible = single_button_press

func toggle_button_selected_variation(is_selected: bool):
	on_click_button.theme_type_variation = "selected" if is_selected else ""

func _on_on_click_button_pressed() -> void:
	on_screen_ui.on_spell_slot_clicked(index)

func on_cooldown(cooldown_timer: float):
	color_rect.visible = true
	var elapsed_time = 0.0
	while elapsed_time < cooldown_timer:
		elapsed_time += get_process_delta_time()
		var progress = elapsed_time / cooldown_timer
		color_rect.size = Vector2(40, progress * 40)
		await get_tree().process_frame

	color_rect.size = Vector2(40, 0)
	color_rect.visible = false

func _on_on_click_button_mouse_entered() -> void:
	v_box_container.show()
	damage_label.text = str(on_screen_ui.spell_configs[index].damage) + " damage"
	cooldown_label.text = str(on_screen_ui.spell_configs[index].initial_cooldown) + " cooldown"
	mana_label.text = str(on_screen_ui.spell_configs[index].mana) + " mana"

func _on_on_click_button_mouse_exited() -> void:
	v_box_container.hide()
