extends Node

signal gold_gained(amount_gained)
signal gold_used(amount_used)

signal update_gold_label(updated_gold_total)

var gold_total: float = 0.0

func _ready() -> void:
	gold_gained.connect(on_gold_gained)
	gold_used.connect(on_gold_used)


func on_gold_gained(amount_gained):
	gold_total += amount_gained
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	scrap_heap.update_label_text()

	update_gold_label.emit(gold_total)

func on_gold_used(amount_used):
	gold_total -= amount_used
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	scrap_heap.update_label_text()

	update_gold_label.emit(gold_total)
