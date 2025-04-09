extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.player == null or actor.position.distance_to(actor.player.position) > blackboard.get_value("detection range"):
		return FAILURE
	return SUCCESS
