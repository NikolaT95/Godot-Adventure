extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_from_player()
	if distance_from_player == -1:
		return SUCCESS
	if distance_from_player <= blackboard.get_value("detection range"):
		return SUCCESS
	else:
		return FAILURE
