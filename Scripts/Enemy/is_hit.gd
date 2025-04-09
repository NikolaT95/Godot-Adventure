extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_hit == true:
		return SUCCESS
	else:
		return FAILURE
