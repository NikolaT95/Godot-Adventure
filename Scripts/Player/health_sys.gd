extends Node

class_name  PotionSystem

signal died
signal damage_taken(current_health: int)
signal mana_spent(current_mana: int)

@export var canvas_item: CanvasItem
@export var material: Material
@onready var on_screen_ui: InventoryUI = $"../OnScreenUI"
@onready var player: Player = $".."
@onready var use_potion: AudioStreamPlayer = $"../Sounds/UsePotion"

@export var max_health:int
var current_health: int
@export var max_mana: int
var current_mana: int
var index
var potion: PotionPickUp = null

func init():
	max_health = 100 + (player.level * 10)
	current_health = max_health
	max_mana = 100 + (player.level * 10)
	current_mana = max_mana

func apply_damage(damage: int):
	current_health = current_health-damage
	damage_taken.emit(current_health)
	if current_health <= 0:
		died.emit()
	canvas_item.material = material
	await get_tree().create_timer(0.1).timeout
	canvas_item.material = null

func spend_mana(mana_to_spend: int):
	current_mana -= mana_to_spend
	mana_spent.emit(current_mana)

func _input(_event: InputEvent) -> void:
	if potion != null:
		if Input.is_action_just_pressed("heal") and potion.health>0:
			current_health += potion.health
			if current_health > max_health:
				current_health = max_health
			on_screen_ui.apply_damage_to_health_bar(current_health)
			on_screen_ui.take_stack(index)
			use_potion.play()
		elif Input.is_action_just_pressed("heal") and potion.mana>0:
			current_mana += potion.mana
			if current_mana > max_mana:
				current_mana = max_mana
			on_screen_ui.apply_mana_to_mana_bar(current_mana)
			on_screen_ui.take_stack(index)
			use_potion.play()
