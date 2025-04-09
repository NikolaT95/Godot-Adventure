extends Node

@onready var player: Player = $".."
@onready var potion_system: PotionSystem = $"../PotionSystem"
@onready var on_screen_ui: InventoryUI = $"../OnScreenUI"
var buff: BuffPickUp

func set_active_buff(item: Variant):
	buff = item
	if item.speed > 0:
		player.speed += item.speed
	elif item.health > 0:
		potion_system.max_health += item.health
		on_screen_ui.change_health_bar(potion_system.max_health)

func deactivate_buff():
	if buff != null:
		if buff.speed > 0:
			player.speed -= buff.speed
		elif buff.health > 0:
			potion_system.max_health -= buff.health
			on_screen_ui.change_health_bar(potion_system.max_health)
		buff=null
