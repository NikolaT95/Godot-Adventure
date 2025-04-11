extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.has_method("move_and_slide"):
		actor.velocity = Vector2.ZERO
		actor.move_and_slide()

	return RUNNING
