extends CanvasLayer

class_name InventoryUI

@onready var inventory: Inventory = $"../Inventory"
@onready var grid_container: GridContainer = %GridContainer
@onready var weapon_slot: EquipmentSlot = %WeaponSlot
@onready var buff_slot: EquipmentSlot = %BuffSlot
@onready var spell_slot: EquipmentSlot = %SpellSlot
@onready var potion_slot: EquipmentSlot = %PotionSlot
@onready var combat_system: CombatSystem = $"../CombatSystem"
@onready var spell_slots: Array[SpellSlot]=[
	$GridContainer/Ice,
	$GridContainer/Fire
]
@onready var spell_system: SpellSystem = $"../SpellSystem"
@onready var player: Player = $".."
@onready var buff_system: Node = $"../BuffSystem"
@onready var health_bar: ProgressBar = $VBoxContainer2/HealthBar
@onready var potion_system: PotionSystem = $"../PotionSystem"
@onready var mana_bar: ProgressBar = $VBoxContainer2/ManaBar
@onready var gold: Label = $HBoxContainer3/Gold
@onready var level: Label = $HBoxContainer3/Level
@onready var slots_dictionary = {
	"Weapon": weapon_slot,
	"Buff": buff_slot,
	"Magic": spell_slot,
	"Potion": potion_slot
}
var spell_configs: Array[SpellConfig] = [
	preload("res://Resources/Weapons/Spells/Ice/ice_spell_config.tres"),
	preload("res://Resources/Weapons/Spells/Fire/fire_spell_config.tres")
]
@onready var ice_add_button: Button = $GridContainer/IceAddButton
@onready var fire_add_button: Button = $GridContainer/FireAddButton

func _ready() -> void:
	for i in range(spell_configs.size()):
		spell_configs[i] = spell_configs[i].duplicate(true)

func _process(_delta: float) -> void:
	gold.text = "Gold: " + str(player.gold)
	level.text = "Level: " + str(player.level)

func equip_item_direct(slot_type: String, index: int) -> void:
	var item_to_equip = inventory.items[index]
	equip_item_to_slot(item_to_equip, item_to_equip.slot_type)
	if slot_type == "Weapon":
		combat_system.set_active_weapon(item_to_equip.weapon_item, item_to_equip.slot_type)
	if slot_type == "Magic":
		combat_system.set_active_weapon(item_to_equip.weapon_item, item_to_equip.slot_type)
		spell_slots[0].texture_rect.texture=preload("res://Assets/Images/Items/ice_slot.png")
		spell_slots[1].texture_rect.texture=preload("res://Assets/Images/Items/fire_slot.png")
	if slot_type == "Buff":
		buff_system.deactivate_buff()
		buff_system.set_active_buff(item_to_equip)
	if slot_type == "Potion":
		potion_system.index=index
		potion_system.potion=item_to_equip

func drop_item(index: int)-> void:
	inventory.taken_inventory_slots_count -= 1
	clear_slot_at_index(index)
	inventory.eject_item_into_the_ground(index)

func take_stack(index: int):
	inventory.remove_stack(index)
	if inventory.items[index] != null:
		var inventory_slot: InventorySlot = grid_container.get_child(index)
		inventory_slot.stacks_label.text = str(inventory.items[index].stacks)
		potion_slot.stacks_label.text = str(inventory.items[index].stacks)
	else:
		clear_slot_at_index(index)

func sell_item(index: int):
	inventory.taken_inventory_slots_count -= 1
	clear_slot_at_index(index)
	inventory.sell_inventory_item(index)

func clear_slot_at_index(idx: int):
	var slot = grid_container.get_child(idx)
	if slot is InventorySlot and not slot.is_empty:
		slot.remove_item()

func add_item(item: Variant):
	var empty_slots = grid_container.get_children().filter(func (slot):
		return slot is InventorySlot and slot.is_empty)
	var first_empty_slot = empty_slots.front() as InventorySlot
	first_empty_slot.add_item(item)

func update_stack_at_slot_index(stacks_value: int, inventory_slot_index:int):
	if inventory_slot_index == -1 or inventory_slot_index >= grid_container.get_child_count():
		return
	var inventory_slot: InventorySlot = grid_container.get_child(inventory_slot_index)
	inventory_slot.stacks_label.text = str(stacks_value)

func equip_item_to_slot(item: Variant, slot_to_equip: String):
	slots_dictionary[slot_to_equip].set_equipment_texture(item.texture)
	slots_dictionary[slot_to_equip].set_equipment_stack(item.stacks)
	if slot_to_equip == "Weapon" or slot_to_equip == "Magic":
		slots_dictionary[slot_to_equip].set_equipment_labels(item.name, str(item.level) + " level", str(item.damage) +" damage")
	elif slot_to_equip == "Buff":
		slots_dictionary[slot_to_equip].set_equipment_labels(item.name, str(item.level) + " level", str(item.speed) + " speed" if item.speed > item.health else str(item.health) + " health")
	elif slot_to_equip == "Potion":
		slots_dictionary[slot_to_equip].set_equipment_labels(item.name, str(item.level) + " level", str(item.mana) +" mana" if item.mana > item.health else str(item.health) + " health")

func set_selected_spell_slot(idx: int):
	for i in spell_slots.size():
		spell_slots[i].toggle_button_selected_variation(idx==i)

func unselect_all_slots():
	for slot in spell_slots:
		slot.toggle_button_selected_variation(false)

func is_any_slot_selected() -> bool:
	for slot in spell_slots:
		if slot.on_click_button.theme_type_variation == "selected":
			return true
	return false

func on_spell_slot_clicked(i: int):
	inventory.selected_spell_index = i
	set_selected_spell_slot(i)
	spell_system.on_spell_activated(i)

func spell_cooldown_activated(cooldown: float, idx: int):
	spell_slots[idx].on_cooldown(cooldown)

func init_health_bar(max_health: int):
	health_bar.max_value = max_health
	health_bar.value = max_health

func change_health_bar(max_health: int):
	health_bar.max_value = max_health

func change_mana_bar(max_mana: int):
	mana_bar.max_value = max_mana

func init_mana_bar(max_mana: int):
	mana_bar.max_value = max_mana
	mana_bar.value = max_mana

func add_mana():
	mana_bar.value += 1

func add_health():
	health_bar.value += 1

func apply_damage_to_health_bar(health: int):
	health_bar.value = health

func apply_mana_to_mana_bar(mana: int):
	mana_bar.value = mana

func _on_ice_add_button_pressed() -> void:
	spell_configs[0].damage+=5
	spell_configs[0].initial_cooldown-=5
	spell_configs[0].mana+=10
	ice_add_button.hide()
	fire_add_button.hide()

func _on_fire_add_button_pressed() -> void:
	spell_configs[1].damage+=5
	spell_configs[1].initial_cooldown-=5
	spell_configs[1].mana+=10
	ice_add_button.hide()
	fire_add_button.hide()
