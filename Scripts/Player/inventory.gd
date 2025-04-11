extends Node

class_name Inventory

@onready var buff_system: Node = $"../BuffSystem"
@onready var potion_system: PotionSystem = $"../PotionSystem"
@onready var on_screen_ui: InventoryUI = $"../OnScreenUI"
@onready var player: Player = $".."
@onready var combat_system: CombatSystem = $"../CombatSystem"
@onready var item_drop: AudioStreamPlayer = $"../Sounds/ItemDrop"

var PICKUP_ITEM_SCENES = {
	"Sword": preload("res://Scenes/Items/sword_pick_up.tscn"),
	"Hammer": preload("res://Scenes/Items/hammer_pick_up.tscn"),
	"Magic Blue": preload("res://Scenes/Items/magic_wand_blue_pick_up.tscn"),
	"Boots" : preload("res://Scenes/Items/boots_pickup.tscn"),
	"Armor": preload("res://Scenes/Items/armor_pick_up.tscn"),
	"Health Potion": preload("res://Scenes/Items/health_potion.tscn"),
	"Mana Potion": preload("res://Scenes/Items/mana_potion.tscn")
}

const INVENTORY_CAPACITY = 8
@export var items: Array[Variant] = []
var taken_inventory_slots_count = 0
var selected_spell_index =- 1

func check_inventory_free_space() ->bool:
	if items.size() < INVENTORY_CAPACITY:
		return true
	for i in range(items.size()):
		if items[i] == null:
			return true
	return false

func on_item_equipped(slot_to_equip, idx: int ):
	var item_to_equip = items[idx]
	on_screen_ui.equip_item_to_slot(item_to_equip, slot_to_equip)

func add_item(item: Variant, stacks: int):
	if stacks && item.max_stacks > 1:
		add_stackable_item_to_inventory(item, stacks)
	else:
		add_to_empty_slot(item)

func add_to_empty_slot(item: Variant) -> void:
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			on_screen_ui.add_item(item)
			taken_inventory_slots_count += 1
			return
	items.append(item)
	on_screen_ui.add_item(item)
	taken_inventory_slots_count += 1

func add_stackable_item_to_inventory(item: Variant, stacks: int):
	var item_index =- 1
	for i in items.size():
		if items[i] != null && items[i].name == item.name:
			item_index = i
			break
	if item_index !=- 1:
		var inventory_item = items[item_index]

		if inventory_item.stacks + stacks <= item.max_stacks:
			inventory_item.stacks += stacks
			items[item_index] = inventory_item
			on_screen_ui.update_stack_at_slot_index(inventory_item.stacks, item_index)
		else:
			var stacks_diff = inventory_item.stacks + stacks - item.max_stacks
			inventory_item.stacks = item.max_stacks
			on_screen_ui.update_stack_at_slot_index(inventory_item.max_stacks, item_index)
			var new_item = item.duplicate()
			new_item.stacks = stacks_diff
			add_to_empty_slot(new_item)
	else:
		var new_item = item.duplicate()
		new_item.stacks = stacks
		add_to_empty_slot(new_item)

func remove_stack(idx: int):
	var inventory_item = items[idx]
	inventory_item.stacks -= 1
	if inventory_item.stacks == 0:
		potion_system.potion = null
		on_screen_ui.potion_slot.set_equipment_texture(null)
		on_screen_ui.potion_slot.set_equipment_stack(0)
		items[idx] = null

func eject_item_into_the_ground(idx: int):
	var inventory_item_to_eject = items[idx]

	var item_to_eject_as_pickup = PICKUP_ITEM_SCENES[inventory_item_to_eject.name].instantiate()

	item_to_eject_as_pickup.inventory_item = inventory_item_to_eject
	item_to_eject_as_pickup.stacks = inventory_item_to_eject.stacks
	GlobalScene.taken_items.erase(item_to_eject_as_pickup.name)
	#get_tree().PickUpItems.add_child(item_to_eject_as_pickup)
	get_node("/root/Game/PickUpItems").add_child(item_to_eject_as_pickup)
	item_to_eject_as_pickup.disable_collision()
	item_to_eject_as_pickup.global_position=get_parent().global_position

	var eject_direction = player.last_direction

	if eject_direction.x == 0:
		eject_direction.x = randf_range(-1,1)
	else:
		eject_direction.y = randf_range(-1,1)

	var eject_position = get_parent().global_position+Vector2(30,30)*eject_direction

	var speed = 100
	var direction = (eject_position - item_to_eject_as_pickup.position).normalized()

	while item_to_eject_as_pickup.global_position.distance_to(eject_position) > 1:
		item_to_eject_as_pickup.global_position += direction * speed * get_process_delta_time()
		await get_tree().process_frame

	item_to_eject_as_pickup.global_position = eject_position
	item_to_eject_as_pickup.enable_collision()
	item_drop.play()

	clear_equipped_item(inventory_item_to_eject)
	items[idx]=null

func sell_inventory_item(idx: int):
	var inventory_item_to_sell = items[idx]
	clear_equipped_item(inventory_item_to_sell)
	items[idx] = null
	player.gold += inventory_item_to_sell.price

func clear_equipped_item(item):
	match item.slot_type:
		"Weapon", "Magic":
			if combat_system.weapon_ == item.weapon_item:
				combat_system.weapon_ = null
				on_screen_ui.weapon_slot.set_equipment_texture(null)
				on_screen_ui.weapon_slot.set_equipment_labels("","","")
			elif combat_system.magic_wand_ == item.weapon_item:
				combat_system.magic_wand_ = null
				on_screen_ui.spell_slot.set_equipment_texture(null)
				on_screen_ui.spell_slots[0].texture_rect.texture = preload("res://Assets/Images/Items/ice_slot_empty.png")
				on_screen_ui.spell_slots[1].texture_rect.texture = preload("res://Assets/Images/Items/fire_slot_empty.png")
				on_screen_ui.spell_slot.set_equipment_labels("","","")
		"Buff":
			if buff_system.buff == item:
				buff_system.deactivate_buff()
				on_screen_ui.buff_slot.set_equipment_texture(null)
				on_screen_ui.buff_slot.set_equipment_labels("","","")
		"Potion":
			if potion_system.potion == item:
				potion_system.potion = null
				on_screen_ui.potion_slot.set_equipment_texture(null)
				on_screen_ui.potion_slot.set_equipment_stack(0)
				on_screen_ui.potion_slot.set_equipment_labels("","","")
