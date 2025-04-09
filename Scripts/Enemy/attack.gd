extends ActionLeaf

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.attack(actor.player, "Melee")
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.is_hit == true:
		return FAILURE
	if actor.is_attacking == false:
		return SUCCESS
	if actor.position.distance_to(actor.player.position) > blackboard.get_value("attack range") + 1:
		actor.is_attacking = false
		return FAILURE
	return RUNNING
