extends ActionLeaf

var pause_time: float = 3.0
var timer: float
func before_run(actor: Node, _blackboard: Blackboard) -> void:
	timer = 0.0
	actor.stop_walking()
func tick(actor: Node, blackboard: Blackboard) -> int:
	timer += get_process_delta_time()
	if timer >= pause_time:
		timer = 0.0
		return SUCCESS
	if actor.position.distance_to(actor.player.position) > blackboard.get_value("attack range") + 10:
		return FAILURE
	if actor.is_hit == true:
		return FAILURE
	return RUNNING
