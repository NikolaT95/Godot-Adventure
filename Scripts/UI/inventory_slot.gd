extends VBoxContainer

class_name  InventorySlot

var is_empty=true
@export var single_button_press=false
@export var starting_texture: Texture
@export var start_label: String
@export var index: int

@onready var on_screen_ui: InventoryUI = $"../../.."
@onready var texture_rect: TextureRect = $NinePatchRect/MenuButton/CenterContainer/TextureRect
@onready var stacks_label: Label = $NinePatchRect/StacksLabel
@onready var menu_button: MenuButton = $NinePatchRect/MenuButton
@onready var label: Label = $"../../Label"
@onready var v_box_container: VBoxContainer = $"../.."
var merchant: Merchant = null
var shopping_ui: ShoppingUI = null
var slot_to_equip="NotEquipable"
@onready var labels: VBoxContainer = $NinePatchRect/VBoxContainer
@onready var name_label: Label = $NinePatchRect/VBoxContainer/NameLabel
@onready var price_label: Label = $NinePatchRect/VBoxContainer/PriceLabel
@onready var level_label: Label = $NinePatchRect/VBoxContainer/LevelLabel
@onready var property_label: Label = $NinePatchRect/VBoxContainer/PropertyLabel

func _ready() -> void:
	if starting_texture!=null:
		texture_rect.texture=starting_texture
	if start_label!=null:
		name_label.text=start_label
	menu_button.disabled=!single_button_press

	var popup_menu= menu_button.get_popup()
	popup_menu.id_pressed.connect(on_popup_menu_item_pressed)

	if get_tree().current_scene.name == "Game" and merchant == null:
		merchant = $"../../../../../Merchant"
		shopping_ui = $"../../../../../Merchant/ShoppingUI"
		merchant.shop.connect(change_menu)
		merchant.close_shop.connect(change_menu)

func _process(_delta: float) -> void:
	if get_tree().current_scene.name == "Game" and merchant == null:
		merchant = $"../../../../../Merchant"
		shopping_ui = $"../../../../../Merchant/ShoppingUI"
		merchant.shop.connect(change_menu)
		merchant.close_shop.connect(change_menu)

func on_popup_menu_item_pressed(id: int):
	var pressed_menu_item=menu_button.get_popup().get_item_text(id)
	if pressed_menu_item=="Drop":
		on_screen_ui.drop_item(index)
		menu_button.disabled= true
	if pressed_menu_item.contains("Equip") && slot_to_equip !="NotEquipable":
		on_screen_ui.equip_item_direct(slot_to_equip, index)
	if pressed_menu_item=="Sell":
		on_screen_ui.sell_item(index)

func _on_texture_rect_mouse_entered() -> void:
	labels.show()

func _on_texture_rect_mouse_exited() -> void:
	labels.hide()

func add_item(item: Variant):
	if merchant.is_shopping==false:
		var popup_menu: PopupMenu=menu_button.get_popup()
		var equip_slot_name_array= item.slot_type.to_lower().split("_")
		var equip_slot_name= " ".join(equip_slot_name_array)
		slot_to_equip=item.slot_type
		popup_menu.set_item_text(0, "Equip to "+ equip_slot_name)
	slot_to_equip=item.slot_type
	is_empty=false
	menu_button.disabled=false
	texture_rect.texture=item.texture
	name_label.text=item.name
	price_label.text=str(item.price)+"💰"
	level_label.text=str(item.level)+ " lvl"
	if item.slot_type == "Weapon" or item.slot_type == "Magic":
		property_label.text=str(item.damage) + " dmg"
	if item.slot_type == "Potion":
		if item.health>0:
			property_label.text=str(item.health) + " H"
		elif item.mana>0:
			property_label.text=str(item.mana) + " M"
	if item.slot_type == "Buff":
		if item.health>0:
			property_label.text=str(item.health) + " H"
		elif item.speed>0:
			property_label.text=str(item.speed) + " S"
	if item.stacks >= 2:
		stacks_label.text=str(item.stacks)

func remove_item():
	is_empty=true
	menu_button.disabled=true
	texture_rect.texture=null
	name_label.text=""
	price_label.text=""
	stacks_label.text=""

func change_menu():
	var popup_menu= menu_button.get_popup()
	popup_menu.clear()
	if merchant.is_shopping:
		popup_menu.add_item("Sell", 0)
		label.text="Sell items"
		v_box_container.scale=Vector2(1.1, 1.1)
	else:
		v_box_container.scale=Vector2(1.0, 1.0)
		label.text="Inventory"
		popup_menu.add_item("Equip", 0)
		var equip_slot_name_array= slot_to_equip.to_lower().split("_")
		var equip_slot_name= " ".join(equip_slot_name_array)
		popup_menu.set_item_text(0, "Equip to "+ equip_slot_name)
		popup_menu.add_item("Drop", 1)
