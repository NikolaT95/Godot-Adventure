extends Sprite2D

class_name Merchant

signal shop
signal close_shop

@export var items_to_buy: Array[Resource]
@onready var label: Label = $Label
@onready var shopping_ui: ShoppingUI = $ShoppingUI as ShoppingUI
var player: Player = null
var can_trigger_merchant_ui
var is_shopping = false

func _ready() -> void:
	shopping_ui.items_to_buy = items_to_buy
	shopping_ui.setup_buying_grid()
	label.visible = false

func _on_area_2d_body_entered(_body: Node2D) -> void:
	can_trigger_merchant_ui = true
	label.visible = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	can_trigger_merchant_ui = false
	label.visible = false
	shopping_ui.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("merchant") and can_trigger_merchant_ui:
		shopping_ui.visible = true
		is_shopping = true
		player = get_node_or_null("../Player") as Player
		shopping_ui.items_to_sell = (player.find_child("Inventory")as Inventory).items
		shop.emit()
	if Input.is_action_just_pressed("ui_cancel") && shopping_ui.visible:
		shopping_ui.visible = false
		is_shopping = false
		close_shop.emit()
