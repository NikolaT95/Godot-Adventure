extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:

	actor.move_to_character(actor.player)
	if actor.global_position.distance_to(actor.player.position) > blackboard.get_value("detection range"):
		return FAILURE
	if actor.is_hit == true:
		return SUCCESS

	if actor.global_position.distance_to(actor.player.position) < blackboard.get_value("attack range"):
		return SUCCESS
	return RUNNING
