extends ActionLeaf


var target_position: Vector2 = Vector2.ZERO
var last_position: Vector2 = Vector2.ZERO
var timer: float
func before_run(actor: Node, blackboard: Blackboard) -> void:
	target_position = actor.position + Vector2(randf_range(-blackboard.get_value("wander radius"), blackboard.get_value("wander radius")), randf_range(-blackboard.get_value("wander radius"), blackboard.get_value("wander radius")))
	last_position = Vector2(INF, INF)
	timer = 0.0
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.player !=null and actor.global_position.distance_to(actor.player.position) <= blackboard.get_value("detection range"):
		return FAILURE
	if actor.position.distance_to(target_position) < blackboard.get_value("move threshold"):
		return SUCCESS
	if actor.position.distance_to(last_position) < blackboard.get_value("move threshold"):
		timer = timer + get_process_delta_time()
		if timer >= blackboard.get_value("stuck threshold"):
			return SUCCESS
	else:
		timer = 0.0
		last_position = actor.position
	actor.wander(target_position)

	return RUNNING

func after_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.stop_walking()
