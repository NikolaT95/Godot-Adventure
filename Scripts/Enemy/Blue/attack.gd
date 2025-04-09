extends ActionLeaf

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.attack(actor.closest_friend, "Range")
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_hit == true:
		return FAILURE
	if actor.is_attacking == false:
		return SUCCESS
	#if actor.closest_friend != null and actor.position.distance_to(actor.closest_friend.position) > blackboard.get_value("heal range") + 30:
		#print("prika pobegao")
		#actor.is_attacking = false
		#return FAILURE
	return RUNNING
