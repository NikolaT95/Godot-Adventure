extends ActionLeaf

var pause_time: float = 5.0
var timer: float
func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	timer = 0.0
func tick(actor: Node, blackboard: Blackboard) -> int:
	timer += get_process_delta_time()
	if timer >= pause_time:
		timer = 0.0
		return SUCCESS
	if actor.player!=null and actor.global_position.distance_to(actor.player.position) <= blackboard.get_value("detection range"):
		return FAILURE
	return RUNNING
