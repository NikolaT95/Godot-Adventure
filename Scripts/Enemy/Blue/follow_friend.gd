extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if  actor.closest_friend == null:
		return FAILURE
	if actor.global_position.distance_to(actor.closest_friend.position) > blackboard.get_value("detection range"):
		return FAILURE
	if actor.is_hit == true:
		return FAILURE
	if actor.closest_friend.is_hit == true:
		return SUCCESS
	if actor.global_position.distance_to(actor.closest_friend.position) < blackboard.get_value("heal range") - 10:
		actor.stop_walking()
		return SUCCESS

	actor.move_to_character(actor.closest_friend)
	return RUNNING
