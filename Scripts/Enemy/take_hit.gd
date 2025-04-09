extends ActionLeaf

@export var canvas_item: CanvasItem
@export var material: Material
func before_run(actor: Node, _blackboard: Blackboard) -> void:
	canvas_item.material=material
	actor.is_attacked()
	actor.in_danger = true
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_hit == true:
		return RUNNING
	else:
		return SUCCESS

func after_run(_actor: Node, _blackboard: Blackboard) -> void:
	canvas_item.material=null
