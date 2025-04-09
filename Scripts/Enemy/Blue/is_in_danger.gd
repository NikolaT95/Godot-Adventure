extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_from_player()
	if distance_from_player == -1:
		return FAILURE
	if distance_from_player <= blackboard.get_value("heal range") and actor.in_danger == true:
		return SUCCESS
	return FAILURE
