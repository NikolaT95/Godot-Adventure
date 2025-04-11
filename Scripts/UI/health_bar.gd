extends ProgressBar

@onready var enemy: Enemy = $".."

func _ready() -> void:
	max_value = enemy.max_health
	value = enemy.max_health
	enemy.damage_taken.connect(on_damage_taken)

func on_damage_taken(current_health: int):
	value = current_health
