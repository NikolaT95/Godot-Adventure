extends VBoxContainer

class_name EquipmentSlot

@onready var slot_label: Label = $SlotLabel
@onready var texture_rect: TextureRect = %TextureRect
@onready var stacks_label: Label = $NinePatchRect/StacksLabel
@export var slot_name: String
@onready var name_label: Label = $NinePatchRect/VBoxContainer/NameLabel
@onready var level_label: Label = $NinePatchRect/VBoxContainer/LevelLabel
@onready var propery_label: Label = $NinePatchRect/VBoxContainer/ProperyLabel
@onready var v_box_container: VBoxContainer = $NinePatchRect/VBoxContainer

func _ready() -> void:
	slot_label.text = slot_name

func set_equipment_texture(texture: Texture):
	texture_rect.texture = texture

func set_equipment_stack(stack: int):
	if stack == 0:
		stacks_label.text = ""
	elif stack > 1:
		stacks_label.text = str(stack)

func set_equipment_labels(equipment_name: String, equipment_level: String, equipment_property: String):
	name_label.text = equipment_name
	level_label.text = equipment_level
	propery_label.text = equipment_property

func _on_button_pressed() -> void:
	if v_box_container.visible == false && !name_label.text.is_empty():
		v_box_container.show()
	else:
		v_box_container.hide()


func _on_button_mouse_exited() -> void:
	v_box_container.hide()
