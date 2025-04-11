extends HBoxContainer

class_name  BuySlot

var is_empty=true
#var is_selected=false
@export var single_button_press=false
@export var starting_texture: Texture
@export var start_label: String
@export var index: int
@onready var shopping_ui: ShoppingUI = $"../../../../../.."
@onready var texture_rect: TextureRect = $VBoxContainer2/NinePatchRect/MenuButton/CenterContainer/TextureRect
@onready var stacks_label: Label = $VBoxContainer2/NinePatchRect/StacksLabel
@onready var on_click_button: Button = $VBoxContainer2/NinePatchRect/OnClickButton
@onready var menu_button: MenuButton = $VBoxContainer2/NinePatchRect/MenuButton
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var name_label: Label = $VBoxContainer2/NameLabel
@onready var property_label: Label = $VBoxContainer/PropertyLabel
var slot_to_equip="NotEquipable"

func _ready() -> void:
	if starting_texture != null:
		texture_rect.texture = starting_texture
	if start_label != null:
		name_label.text = start_label
	menu_button.disabled = single_button_press
	on_click_button.disabled =! single_button_press
	on_click_button.visible = single_button_press

func add_item(item: Variant):
	if item.slot_type != "NotEquipable":
		var popup_menu: PopupMenu = menu_button.get_popup()
		var equip_slot_name_array = item.slot_type.to_lower().split("_")
		var equip_slot_name= " ".join(equip_slot_name_array)
		popup_menu.set_item_text(0, "Equip to "+ equip_slot_name)

	is_empty = false
	menu_button.disabled = false
	texture_rect.texture = item.texture
	name_label.text = item.name
	level_label.text = str(item.level) + " level"
	if item.slot_type == "Weapon" or item.slot_type == "Magic":
		property_label.text = str(item.damage) + " damage"
	elif item.slot_type == "Potion":
		if item.health > 0:
			property_label.text = str(item.health) + " health"
		elif item.mana > 0:
			property_label.text = str(item.mana) + " mana"
	elif item.slot_type == "Buff":
		if item.health > 0:
			property_label.text = str(item.health) + " health"
		elif item.speed > 0:
			property_label.text = str(item.speed) + " speed"
	price_label.text = str(item.price) + "💰"
	if item.stacks >= 2:
		stacks_label.text = str(item.stacks)

func remove_item():
	is_empty = true
	menu_button.disabled = true
	texture_rect.texture = null
	name_label.text = ""
	price_label.text = ""
	stacks_label.text = ""

func toggle_button_selected_variation(is_selected: bool):
	on_click_button.theme_type_variation = "selected" if is_selected else ""

func _on_on_click_button_pressed() -> void:
	shopping_ui.on_buy_slot_clicked(index)

func show_price_tag(price: int):
	price_label.text = str(price) + " gold"
	price_label.show()
