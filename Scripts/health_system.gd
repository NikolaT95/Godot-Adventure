extends Node

class_name  HealthSystem


signal damage_taken(current_health: int)

@export var max_health:int
var current_health: int
func init(health: int):
	max_health=health
	current_health=health

func apply_damage(damage: int):
	current_health = current_health-damage
	damage_taken.emit(current_health)
