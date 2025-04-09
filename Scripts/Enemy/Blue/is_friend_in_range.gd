extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.get_closest_enemy_red(blackboard.get_value("detection range"))
	if actor.closest_friend == null:
		actor.in_danger = true
		return FAILURE
	elif actor.in_danger == true:
		return FAILURE
	else:
		actor.in_danger = false
		return SUCCESS
