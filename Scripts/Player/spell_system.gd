extends Node

class_name SpellSystem

var spell_configs: Array[SpellConfig] = [
	preload("res://Resources/Weapons/Spells/Ice/ice_spell_config.tres"),
	preload("res://Resources/Weapons/Spells/Fire/fire_spell_config.tres")
]
@onready var on_screen_ui: InventoryUI = $"../OnScreenUI"
@onready var inventory: Inventory = $"../Inventory"
@onready var combat_system: CombatSystem = $"../CombatSystem"
const SPELL_SCENE = preload("res://Scenes/Player/spell.tscn")
@onready var player: Player = $".."
@onready var potion_system: PotionSystem = $"../PotionSystem"

var current_spell_cooldown: Array = [null, null]
var current_spell_mana: int
var current_spell = -1
var cooldown_timer: Array = [1000,1000]
var screen_rect: Rect2
var spell: Spell = null

func _process(delta: float) -> void:
	for i in range(cooldown_timer.size()):
		if current_spell_cooldown[i] !=null && cooldown_timer[i] < current_spell_cooldown[i]:
			cooldown_timer[i] += delta

func on_cast_active_spell():
	if current_spell ==- 1:
		return
	var spell_direction = player.last_direction.round()
	var spell_config = spell_configs[current_spell]

	if cooldown_timer[current_spell] != 0 and cooldown_timer[current_spell] < current_spell_cooldown[current_spell]:
		return
	else:
		cooldown_timer[current_spell] = 0

	on_screen_ui.spell_cooldown_activated(current_spell_cooldown[current_spell], current_spell)
	spell = SPELL_SCENE.instantiate()
	get_tree().root.add_child(spell)
	spell.direction = spell_direction
	spell.init(spell_config)
	spell.position = player.global_position
	potion_system.spend_mana(current_spell_mana)
	spell.animation_player.play(spell_config.spell_name+" " + direction_to_string(spell_direction))
	on_screen_ui.unselect_all_slots()

func direction_to_string(direction: Vector2) -> String:
	if direction == Vector2.LEFT:
		return "left"
	elif direction == Vector2.RIGHT:
		return "right"
	elif direction == Vector2.UP:
		return "up"
	elif direction == Vector2.DOWN:
		return "down"
	elif direction == Vector2(-1, -1):
		return "left"
	elif direction == Vector2(1, -1):
		return "right"
	elif direction == Vector2(-1, 1):
		return "left"
	elif direction == Vector2(1, 1):
		return "right"
	else:
		return "none"

func on_spell_activated(idx: int):
	var spell_config = spell_configs[idx]
	current_spell = idx
	current_spell_cooldown[current_spell] = spell_config.initial_cooldown
	current_spell_mana = spell_config.mana
