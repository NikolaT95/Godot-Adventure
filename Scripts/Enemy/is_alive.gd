extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.current_health > 0:
		return SUCCESS
	else:
		return FAILURE
