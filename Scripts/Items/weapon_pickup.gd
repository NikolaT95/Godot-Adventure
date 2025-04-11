extends Resource

class_name WeaponPickUp

var stacks=1

@export var slot_type: String="Weapon"

@export var name: String
@export var level: int
@export var damage: int
@export var texture: Texture2D
@export var ground_collision_shape: RectangleShape2D
@export var max_stacks: int
@export var price: int
@export var weapon_item: WeaponItem
