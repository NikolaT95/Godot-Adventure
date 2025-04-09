extends ActionLeaf

var target_position: Vector2 = Vector2.ZERO
var last_position: Vector2 = Vector2.ZERO
var timer: float
var direction: Vector2
func get_new_direction(old_direction: Vector2) -> Vector2:
	var rotate_left = randi() % 2 == 0  # Nasumično bira levo ili desno
	return old_direction.rotated(deg_to_rad(90) if rotate_left else deg_to_rad(-90))

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	direction = (actor.position - actor.player.position).normalized()
	target_position = actor.position + direction * 50
	last_position = actor.position
	timer = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.position.distance_to(target_position) < blackboard.get_value("move threshold"):
		return FAILURE
	if actor.position.distance_to(last_position) < blackboard.get_value("move threshold"):
		timer += get_process_delta_time()
		if timer >= blackboard.get_value("stuck threshold"):
			direction = get_new_direction(direction)
			target_position = actor.position + direction * 50
			timer = 0.0
	else:
		timer = 0.0

	if actor.is_hit == true:
		return SUCCESS

	last_position = actor.position
	actor.wander(target_position)
	return RUNNING

func after_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.stop_walking()
