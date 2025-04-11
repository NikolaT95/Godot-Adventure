extends Area2D

class_name SwordPickUp


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var inventory_item: WeaponPickUp
@export var stacks = 1
