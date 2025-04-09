extends ActionLeaf


var target_position: Vector2 = Vector2.ZERO
var last_position: Vector2 = Vector2.ZERO
func before_run(actor: Node, blackboard: Blackboard) -> void:
	target_position = actor.position + Vector2(randf_range(-blackboard.get_value("wander radius"), blackboard.get_value("wander radius")), randf_range(-blackboard.get_value("wander radius"), blackboard.get_value("wander radius")))
	last_position = actor.position
	blackboard.set_value("timer", 0.0)
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.closest_friend != null:
		return FAILURE
	if actor.position.distance_to(target_position) < blackboard.get_value("move threshold"):
		return SUCCESS
	if actor.position.distance_to(last_position) < blackboard.get_value("move threshold"):
		blackboard.set_value("timer", blackboard.get_value("timer") + get_process_delta_time())
		if blackboard.get_value("timer") >= blackboard.get_value("stuck threshold"):
			return SUCCESS
	else:
		blackboard.set_value("timer", 0.0)
	actor.wander(target_position)
	last_position = actor.position
	return RUNNING

func after_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.stop_walking()
