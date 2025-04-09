extends Area2D

class_name Spell

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var lifetime: float = 3.0
@onready var timer: Timer = Timer.new()
@onready var magic_hit: AudioStreamPlayer = $MagicHit

var direction: Vector2
var speed: float
var damage: int
var mana: int
var shooter: Enemy

func init(config: SpellConfig):
	collision_shape_2d.shape = config.collision_shape
	damage = config.damage
	name = config.spell_name
	speed = config.speed
	mana = config.mana
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(on_lifetime_expired)
	timer.start()

func _process(delta: float) -> void:
	position += speed * delta * direction

func _on_area_entered(area: Area2D) -> void:
	if name.contains("heal") and area.get_parent().is_in_group("enemy_red"):
		var enemy = area.get_parent() as Enemy
		if enemy != shooter:
			enemy.apply_heal(damage)
			queue_free()
	elif name.contains("heal") and area.get_parent() is Player:
		var player = area.get_parent() as Player
		player.potion_system.apply_damage(damage)
		queue_free()
	elif !name.contains("heal") and area.get_parent() is Enemy:
		var enemy = area.get_parent() as Enemy
		enemy.apply_damage(damage)
		enemy.is_hit = true
		queue_free()
	magic_hit.play()

func on_lifetime_expired():
	queue_free()
