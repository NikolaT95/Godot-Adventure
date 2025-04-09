extends SelectorComposite

func update_utility_scores(actor: Node, blackboard: Blackboard):
	if not actor.player:
		return

	var distance = actor.global_position.distance_to(actor.player.global_position)
	var health = actor.current_health

	# Melee Attack Utility (higher when close to enemy)
	var melee_score = clamp(1.0 - (distance / 100.0), 0.0, 1.0) # Closer = higher score

	# Ranged Attack Utility (higher when in effective range)
	var ranged_score = snapped(clamp(1.0 - abs(distance - 100) / 100.0, 0.0, 1.0), 0.1)

	# Flee Utility (higher when low on health)
	var flee_score = clamp(1.0 - (float(health) / float(actor.max_health)), 0.0, 1.0)  # Lower health = higher score
	if !actor.is_enemy_nearby(blackboard.get_value("detection range")):
		flee_score = 0
	# Store scores in the blackboard
	blackboard.set_value("utility_score_SequenceCompositeMelee", melee_score, str(actor.get_instance_id()))
	blackboard.set_value("utility_score_AlwaysSucceedDecorator", ranged_score, str(actor.get_instance_id()))
	blackboard.set_value("utility_score_Flee", flee_score, str(actor.get_instance_id()))


func get_utility_score(child: Node, actor: Node, blackboard: Blackboard) -> float:
	# Default behavior: Use a blackboard-stored score if available, otherwise 1.0
	return blackboard.get_value("utility_score_" + child.name, 1.0, str(actor.get_instance_id()))

func tick(actor: Node, blackboard: Blackboard) -> int:
	update_utility_scores(actor, blackboard)
	var children = get_children()

	# Step 1: Compute utility scores
	var scored_children = []
	for c in children:
		var score = get_utility_score(c, actor, blackboard)
		scored_children.append({ "node": c, "score": score })

	# Step 2: Sort by highest score first
	scored_children.sort_custom(func(a, b): return a["score"] > b["score"])
	#print(scored_children)
	# Step 3: Execute children in sorted order
	for entry in scored_children:
		var c = entry["node"]

		# Reset last_execution_index to avoid skipping nodes
		last_execution_index = 0

		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				_cleanup_running_task(c, actor, blackboard)
				c.after_run(actor, blackboard)
				return SUCCESS
			FAILURE:
				_cleanup_running_task(c, actor, blackboard)
				# Do not increase last_execution_index, since we need a fresh re-evaluation in the next tick
				c.after_run(actor, blackboard)
			RUNNING:
				running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	# If no child succeeds or runs, return FAILURE
	return FAILURE
