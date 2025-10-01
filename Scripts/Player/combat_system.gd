extends Node2D

class_name CombatSystem

@onready var combat_system: CombatSystem = $"."
@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var weapon_collision_shape_2d: CollisionShape2D = $WeaponSprite/Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: Player = $".."
@onready var magic_wand_sprite: Sprite2D = $MagicWandSprite
@onready var magic_wand_collision_shape_2d: CollisionShape2D = $MagicWandSprite/Area2D/CollisionShape2D
@onready var spell_system: SpellSystem = $"../SpellSystem"
@onready var on_screen_ui: InventoryUI = $"../OnScreenUI"
@onready var potion_system: PotionSystem = $"../PotionSystem"
@onready var melee_hit: AudioStreamPlayer = $"../Sounds/MeleeHit"

@export var weapon_: WeaponItem
@export var magic_wand_: WeaponItem
var is_attacking=false
var is_attacking_magic=false

func _physics_process(_delta: float) -> void:
	if player.is_dead == false:
		if Input.is_action_just_pressed("magic_attack") and magic_wand_ != null and on_screen_ui.is_any_slot_selected() \
		and potion_system.current_mana>spell_system.current_spell_mana:
			animation_tree.set("parameters/Attack/BlendSpace2D/blend_position", player.last_direction)
			animation_tree.get("parameters/playback").travel("Attack")
			is_attacking_magic = true
			spell_system.on_cast_active_spell()
		elif Input.is_action_just_pressed("magic_attack") and weapon_ != null :
			animation_tree.set("parameters/Attack/BlendSpace2D/blend_position", player.last_direction)
			animation_tree.get("parameters/playback").travel("Attack")
			is_attacking = true

func set_active_weapon(weapon: WeaponItem, slot_to_equip: String):
	if slot_to_equip == "Weapon":
		weapon_collision_shape_2d.shape = weapon.collision_shape
		weapon_sprite.texture = weapon.in_hand_texture
		weapon_ = weapon
	if slot_to_equip=="Magic":
		#magic_wand_collision_shape_2d.shape=weapon.collision_shape
		magic_wand_sprite.texture = weapon.in_hand_texture
		magic_wand_ = weapon

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name.contains("Attack") and is_attacking == true:
		weapon_sprite.show()
		weapon_.collision_shape.set_deferred("disabled", false)
	elif anim_name.contains("Attack") and is_attacking_magic == true:
		magic_wand_sprite.show()

func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	weapon_sprite.hide()
	is_attacking = false
	if weapon_ != null:
		weapon_.collision_shape.set_deferred("disabled", true)
	magic_wand_sprite.hide()
	is_attacking_magic = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Area2D and area.get_parent() is Enemy:
		var enemy = area.get_parent() as Enemy
		if is_attacking == true:
			melee_hit.play()
			enemy.apply_damage(weapon_.damage + player.damage)
			enemy.is_hit = true
