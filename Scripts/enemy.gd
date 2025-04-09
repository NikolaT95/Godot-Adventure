extends CharacterBody2D

class_name Enemy
signal damage_taken(current_health: int)

@onready var speed: float = 30 + (level * 0.1)
@onready var damage_to_player = 10 + (level * 2)
@export var level = 1
@onready var health: int = 20 + (level * 10)
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var robot_walk: AudioStreamPlayer2D = $RobotWalk
@onready var game: Node2D = $"../.."
var respawn_time= 30.0
var enemy_scene: PackedScene
const SPELL_SCENE = preload("res://Scenes/spell.tscn")
const GOLD = preload("res://Scenes/gold.tscn")
var wander_speed: float = 20.0
var player: Node2D = null
var is_hit = false
var is_dead = false
var knockback_force = 25
var is_attacking = false
var max_health: int
var current_health: int
var last_target_position: Vector2
var last_direction: Vector2
var in_danger: bool = false
var initial_position: Vector2
func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	max_health = health
	current_health = health
	initial_position = position

func _process(_delta: float) -> void:
	if player == null:
		player = get_parent().get_node("../Player")

func apply_damage(damage: int):
	current_health = current_health - damage
	damage_taken.emit(current_health)

func apply_heal(heal: int):
	current_health = min(current_health + heal, max_health)
	damage_taken.emit(current_health)

func on_died():
	set_physics_process(false)
	collision_shape_2d.set_deferred("disabled", true)
	area_collision_shape_2d.set_deferred("disabled", true)
	animation_tree.get("parameters/playback").travel("Death")
	get_parent().get_node("../Player").update_stats()

func get_distance_from_player():
	if player == null:
		return -1.0
	return position.distance_to(player.position)

func move_to_character(character: Node2D):
	if NavigationServer2D.map_get_iteration_id(get_world_2d().navigation_map) == 0:
		return
	if character == null:
		return
	if last_target_position == null or character.position.distance_to(last_target_position) > 10:
		navigation_agent_2d.target_position = character.position
		last_target_position = character.position
	var direction = (character.position - position).normalized()
	last_direction = direction
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	animation_tree.get("parameters/playback").travel("Walk")
	velocity = position.direction_to(navigation_agent_2d.get_next_path_position()) * speed
	if !robot_walk.playing:
		robot_walk.play()
	move_and_slide()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("Death"):
		queue_free()
		is_dead = true
		var loot_drop = GOLD.instantiate()
		loot_drop.amount = level * 10
		get_parent().get_parent().add_child(loot_drop)
		loot_drop.global_position = position
	if anim_name.contains("Attack"):
		is_attacking = false

func is_attacked():
	var direction = (position - player.position).normalized()*knockback_force
	var new_position = position + direction
	while position.distance_to(new_position) > 1:
		position += direction.normalized() * 100 * get_process_delta_time()
		await get_tree().process_frame
	is_hit = false

func attack(character: CharacterBody2D, attack_type: String):
	is_attacking = true
	var curr_position = position
	var direction = (character.position - position).normalized()
	last_direction = direction
	animation_tree.set("parameters/Attack/BlendSpace2D/blend_position", direction)
	animation_tree.get("parameters/playback").travel("Attack")
	if attack_type == "Melee":
		while not is_inside_player_area():
			if is_hit == true or is_attacking == false:
				break
			position += direction * 100 * get_process_delta_time()
			await get_tree().process_frame
		while position.distance_to(curr_position) > 1:
			if is_hit == true or is_attacking == false:
				break
			position -= direction * 100 * get_process_delta_time()
			await get_tree().process_frame
		is_attacking = false
	elif attack_type == "Range":
		var spell_direction = direction.round()
		var spell = SPELL_SCENE.instantiate()
		get_tree().root.add_child(spell)
		spell.name = "heal"
		spell.shooter = self
		spell.direction = direction
		spell.damage = damage_to_player
		spell.speed = 80
		spell.position = position
		spell.animation_player.play("heal " + direction_to_string(spell_direction))

func is_inside_player_area() -> bool:
	var attack_zone = player.get_node("Area2D")
	if attack_zone and attack_zone.overlaps_area(self.get_node("Area2D")):
		return true
	return false

func wander(target_position):
	if NavigationServer2D.map_get_iteration_id(get_world_2d().navigation_map) == 0:
		print("Navigation map is still updating.")
		return
	navigation_agent_2d.target_position = target_position
	var direction = (target_position - position).normalized()
	last_direction = direction
	animation_tree.set("parameters/Walk/BlendSpace2D/blend_position", direction)
	animation_tree.get("parameters/playback").travel("Walk")
	velocity = position.direction_to(navigation_agent_2d.get_next_path_position()) * wander_speed
	move_and_slide()

func stop_walking():
	animation_tree.set("parameters/Idle/BlendSpace2D/blend_position", last_direction)
	animation_tree.get("parameters/playback").travel("Idle")

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
