extends CharacterBody2D

class_name Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var inventory: Node = $Inventory
@onready var combat_system: CombatSystem = $CombatSystem
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var on_screen_ui: InventoryUI = $OnScreenUI
@onready var ice_add_button: Button = $"OnScreenUI/GridContainer/IceAddButton"
@onready var fire_add_button: Button = $"OnScreenUI/GridContainer/FireAddButton"
@onready var coin_collect: AudioStreamPlayer = $Sounds/CoinCollect
@onready var item_pick_up: AudioStreamPlayer = $Sounds/ItemPickUp
@onready var player_walk: AudioStreamPlayer = $Sounds/PlayerWalk
@onready var level_up: AudioStreamPlayer = $Sounds/LevelUp
@onready var game_over: Label = $"OnScreenUI/GameOver"
@onready var potion_system: PotionSystem = $PotionSystem
@onready var robot_hit: AudioStreamPlayer = $Sounds/RobotHit
@onready var magic_hit: AudioStreamPlayer = $Sounds/MagicHit
@onready var game_over_sound: AudioStreamPlayer = $Sounds/GameOver
@onready var fireworks_particle: CPUParticles2D = $FireworksParticle
@onready var buff_system: Node = $BuffSystem

var mana_regen_rate: float = 1.0
@onready var mana_regen_timer: Timer = Timer.new()
var health_regen_rate: float = 3.0
@onready var health_regen_timer: Timer = Timer.new()
var speed = 4000.0
var gold: int = 0
var level: int = 1
var experience: int = 0
var damage: int = 10 + level * 10
var last_direction = null
var is_dead = false

func _ready() -> void:
	potion_system.init()
	potion_system.died.connect(on_player_dead)
	potion_system.damage_taken.connect(on_damage_taken)
	potion_system.mana_spent.connect(on_mana_spent)
	on_screen_ui.init_health_bar(potion_system.max_health)
	on_screen_ui.init_mana_bar(potion_system.max_mana)
	add_child(health_regen_timer)
	health_regen_timer.wait_time = health_regen_rate
	health_regen_timer.one_shot = false
	health_regen_timer.timeout.connect(_on_health_regen)
	health_regen_timer.start()
	add_child(mana_regen_timer)
	mana_regen_timer.wait_time = mana_regen_rate
	mana_regen_timer.one_shot = false
	mana_regen_timer.timeout.connect(_on_mana_regen)
	mana_regen_timer.start()

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left","right","up","down")
	if direction and (combat_system.is_attacking == false and combat_system.is_attacking_magic==false):
		velocity = direction * speed * delta
		animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", direction)
		animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
		animation_tree.get("parameters/playback").travel("Walk")
		last_direction = direction
		if !player_walk.playing:
			player_walk.play()
	else:
		velocity.x = move_toward(velocity.x, 0, speed*delta)
		velocity.y = move_toward(velocity.y, 0, speed*delta)
		if velocity.length() < 1:
			velocity = Vector2.ZERO
		if velocity == Vector2.ZERO:
			animation_tree.get("parameters/playback").travel("Idle")
	move_and_slide()

func update_stats():
	experience += 10
	var curr_level=level
	level = floor(1 + pow(experience / 10.0, 0.6))
	if curr_level != level:
		level_up.play()
		ice_add_button.show()
		fire_add_button.show()
	potion_system.max_health = 20 + (level * 10)
	potion_system.max_mana = 100 + (level * 10)
	on_screen_ui.change_health_bar(potion_system.max_health)
	on_screen_ui.change_mana_bar(potion_system.max_mana)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Gold:
		GlobalScene.taken_items.append(area.name)
		gold += area.amount
		coin_collect.play()
		area.queue_free()
	elif area.is_in_group("pickup_items") and inventory.check_inventory_free_space():
		GlobalScene.taken_items.append(area.name)
		inventory.add_item(area.inventory_item,area.stacks)
		item_pick_up.play()
		area.queue_free()
	elif area.get_parent() is Enemy or (area.get_parent() is Spell and area.get_parent().name.contains("heal")):
		if area.get_parent() is Enemy:
			robot_hit.play()
		elif area.get_parent() is Spell:
			magic_hit.play()
		var damage_to_player = (area.get_parent() as Enemy).damage_to_player
		potion_system.apply_damage(damage_to_player)

func on_player_dead():
	is_dead = true
	set_physics_process(false)
	combat_system.set_process_input(false)
	game_over.visible = true
	animation_tree.get("parameters/playback").travel("Death")
	game_over_sound.play()
	GlobalScene.music.stop()
	var exit_timer = Timer.new()
	exit_timer.wait_time = 5.0
	exit_timer.one_shot = true
	add_child(exit_timer)
	exit_timer.timeout.connect(_on_exit_to_main_menu)
	exit_timer.start()

func _on_exit_to_main_menu():
	GlobalScene.change_scene("res://Scenes/Menu/main_menu.tscn")

func on_damage_taken(health: int):
	on_screen_ui.apply_damage_to_health_bar(health)

func on_mana_spent(mana: int):
	on_screen_ui.apply_mana_to_mana_bar(mana)

func _on_mana_regen():
	if potion_system.current_mana < potion_system.max_mana:
		potion_system.current_mana += 1
		on_screen_ui.add_mana()

func _on_health_regen():
	if potion_system.current_health < potion_system.max_health:
		potion_system.current_health += 1
		on_screen_ui.add_health()

func player_won():
	set_physics_process(false)
	combat_system.set_process_input(false)
	game_over.text = "You Won"
	game_over.visible = true
	fireworks_particle.emitting = true
	var exit_timer = Timer.new()
	exit_timer.wait_time = 5.0
	exit_timer.one_shot = true
	add_child(exit_timer)
	exit_timer.timeout.connect(_on_exit_to_main_menu)
	exit_timer.start()

func save_game():
	var saved_game = SavedGame.new()
	saved_game.timestamp = Time.get_unix_time_from_system()
	saved_game.position = position
	saved_game.level = level
	saved_game.gold = gold
	saved_game.health = potion_system.current_health
	saved_game.mana = potion_system.current_mana
	saved_game.ice_damage = on_screen_ui.spell_configs[0].damage
	saved_game.ice_initial_cooldown = on_screen_ui.spell_configs[0].initial_cooldown
	saved_game.ice_mana = on_screen_ui.spell_configs[0].mana
	saved_game.fire_damage = on_screen_ui.spell_configs[1].damage
	saved_game.fire_initial_cooldown = on_screen_ui.spell_configs[1].initial_cooldown
	saved_game.fire_mana = on_screen_ui.spell_configs[1].mana
	for item in inventory.items:
		saved_game.inventory.append(item)
	saved_game.taken_items.clear()
	for item_name in GlobalScene.taken_items:
		saved_game.taken_items.append(item_name)
	var save_path = "res://Resources/Player/saved_player.tres"
	ResourceSaver.save(saved_game, save_path)

func load_game():
	var save_path = "res://Resources/Player/saved_player.tres"
	if not FileAccess.file_exists(save_path):
		print("No save file found!")
		return

	var saved_game = ResourceLoader.load(save_path) as SavedGame
	if saved_game == null:
		print("Failed to load save file!")
		return

	position = saved_game.position
	level = saved_game.level
	gold = saved_game.gold
	potion_system.current_health = saved_game.health
	potion_system.current_mana = saved_game.mana
	on_screen_ui.spell_configs[0].damage = saved_game.ice_damage
	on_screen_ui.spell_configs[0].initial_cooldown = saved_game.ice_initial_cooldown
	on_screen_ui.spell_configs[0].mana = saved_game.ice_mana
	on_screen_ui.spell_configs[1].damage = saved_game.fire_damage
	on_screen_ui.spell_configs[1].initial_cooldown = saved_game.fire_initial_cooldown
	on_screen_ui.spell_configs[1].mana = saved_game.fire_mana

	inventory.items.clear()
	for item in saved_game.inventory:
		if item !=null:
			inventory.add_item(item,item.stacks)
	GlobalScene.taken_items.clear()
	for pick_up in saved_game.taken_items:
		GlobalScene.taken_items.append(pick_up)
