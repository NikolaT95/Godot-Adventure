extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.closest_friend != null and actor.closest_friend.current_health<actor.closest_friend.max_health:
		return SUCCESS
	return FAILURE
