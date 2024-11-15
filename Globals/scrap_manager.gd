extends Node

signal scrap_pile_clicked(scrap_pile)
signal scrap_collected(scrap_collected_amount)

signal scrap_gained(amount_gained)
signal scrap_used(amount_used)

signal update_scrap_label(scrap_total_amount)

signal update_scrap_in_crafting_heap(scrap_total_amount)

signal add_scrap_to_hoard(amount)
signal remove_scrap_from_hoard(amount)

signal scrap_all_gone

signal scrap_total_changed(new_total)

var scrap_total = 0

func _ready() -> void:
	scrap_collected.connect(on_scrap_collected)
	scrap_gained.connect(on_scrap_gained)
	scrap_used.connect(on_scrap_used)

	GoblinManager.goblin_collected_item.connect(on_goblin_collected_item)
	GoblinManager.goblin_delivered_item.connect(on_goblin_delivered_item)

func on_scrap_collected(scrap_collected_amount):
	scrap_total += scrap_collected_amount
	if scrap_collected_amount > 0:
		add_scrap_to_hoard.emit(scrap_collected_amount)
		update_scrap_in_crafting_heap.emit(scrap_total)

func on_scrap_gained(amount_gained):
	scrap_total += amount_gained
	update_scrap_in_crafting_heap.emit(scrap_total)
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	scrap_heap.update_label()

	update_scrap_label.emit(scrap_total)
	update_scrap_total(scrap_total)

func on_scrap_used(amount_used):
	scrap_total -= amount_used
	update_scrap_in_crafting_heap.emit(scrap_total)
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	scrap_heap.update_label()

	update_scrap_label.emit(scrap_total)
	update_scrap_total(scrap_total)

func on_goblin_collected_item(from, item, goblin_node):
	from.remove_resource(1, item)

func on_goblin_delivered_item(to, item, goblin_node):
	to.add_resource(1, item)

func update_scrap_total(new_total):
	scrap_total = new_total
	scrap_total_changed.emit(scrap_total)
