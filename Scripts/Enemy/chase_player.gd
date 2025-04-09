extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.player == null:
		return FAILURE

	if actor.global_position.distance_to(actor.player.position) > blackboard.get_value("detection range"):
		return FAILURE
	if actor.is_hit == true:
		return FAILURE

	if actor.global_position.distance_to(actor.player.position) < blackboard.get_value("attack range"):
		return SUCCESS

	actor.move_to_character(actor.player)
	return RUNNING
