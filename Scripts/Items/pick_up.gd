extends Area2D

class_name PickUp

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var inventory_item: Resource
@export var stacks = 1

func disable_collision():
	collision_shape_2d.disabled = true

func enable_collision():
	collision_shape_2d.disabled = false
