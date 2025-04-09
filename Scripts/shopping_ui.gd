extends CanvasLayer

class_name ShoppingUI
@onready var buying_grid_container: GridContainer = %BuyingGridContainer
@onready var buy_button: Button = %BuyButton
const BUY_SLOT = preload("res://Scenes/UI/buy_slot.tscn")
var items_to_buy: Array[Variant]
var items_to_sell: Array[Variant]
@onready var color_rect: ColorRect = $MarginContainer/ColorRect
@onready var margin_container: MarginContainer = $MarginContainer
@onready var player: Player = GlobalScene.player
@onready var cant_buy_label: Label = $MarginContainer/ColorRect/HBoxContainer/MerchantColumn/CantBuyLabel

var selected_sell_item_indexes: Array[int] = []
var selected_buy_item_indexes: Array[int] = []
var selected_index:int =- 1

func _ready() -> void:
	margin_container.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE

func setup_buying_grid():
	for child in buying_grid_container.get_children():
		child.queue_free()

	for i in items_to_buy.size():
		var buying_slot = BUY_SLOT.instantiate() as BuySlot
		buying_slot.single_button_press = true
		buying_grid_container.add_child(buying_slot)
		buying_slot.add_item(items_to_buy[i])
		buying_slot.show_price_tag(items_to_buy[i].price*items_to_buy[i].stacks)
		buying_slot.index = i

func on_buy_slot_clicked(idx: int):
	if selected_buy_item_indexes.has(idx):
		buying_grid_container.get_child(idx).toggle_button_selected_variation(false)
		selected_buy_item_indexes.clear()
	else:
		for i in selected_buy_item_indexes:
			buying_grid_container.get_child(i).toggle_button_selected_variation(false)
		selected_buy_item_indexes.clear()
		buying_grid_container.get_child(idx).toggle_button_selected_variation(true)
		selected_buy_item_indexes.append(idx)
	buy_button.disabled=selected_buy_item_indexes.size() == 0

func _on_buy_button_pressed() -> void:
	for i in selected_buy_item_indexes:
		var item_to_buy = items_to_buy[i]
		if player.gold >= item_to_buy.price and (player.find_child("Inventory") as Inventory).check_inventory_free_space():
			(player.find_child("Inventory") as Inventory).add_item(item_to_buy, item_to_buy.stacks)
			player.gold -= item_to_buy.price
			buying_grid_container.get_child(i).toggle_button_selected_variation(false)
			selected_buy_item_indexes.clear()
		else:
			cant_buy_label.text = "No money or full inventory"
			cant_buy_label.show()
			buying_grid_container.get_child(i).toggle_button_selected_variation(false)
			selected_buy_item_indexes.clear()
			await get_tree().create_timer(1.0).timeout
			cant_buy_label.hide()
	buy_button.disabled = true
