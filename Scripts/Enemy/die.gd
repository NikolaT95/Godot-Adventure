extends ActionLeaf

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	actor.stop_walking()
	actor.on_died()
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_dead == false:
		return RUNNING
	else:
		return SUCCESS
