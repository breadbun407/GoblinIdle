extends Node

signal goblin_left_scrap_heap(goblin, scrap_heap_parent)
signal goblin_left_crafting_heap(goblin, crafting_heap_parent)

signal scrap_heap_goblin_hired
signal crafting_heap_goblin_hired

signal scrap_heap_goblin_fired
signal crafting_heap_goblin_fired

signal update_scrap_goblins_label(total_scrap_goblins)
signal update_crafting_orcs_label(total_crafting_orcs)

signal parent_set_to_heap()

signal goblin_collected_item(from, item, goblin)
signal goblin_delivered_item(to, item, goblin)

signal scrap_pile_goblin_check_travel
signal crafting_goblin_check_craft

signal storage_full(item)

var scrap_heap_goblins_hired_total = 0
var crafting_heap_goblin_hired_total = 0

var scrap_heap_goblins_current = 0
var crafting_heap_goblin_current = 0

func _ready() -> void:
	scrap_heap_goblin_hired.connect(on_scrap_heap_goblin_hired)
	crafting_heap_goblin_hired.connect(on_crafting_heap_goblin_hired)
	scrap_heap_goblin_fired.connect(on_scrap_heap_goblin_fired)
	crafting_heap_goblin_fired.connect(on_crafting_heap_goblin_fired)

func on_scrap_heap_goblin_hired():
	scrap_heap_goblins_hired_total += 1
	scrap_heap_goblins_current += 1
	update_scrap_goblins_label.emit(scrap_heap_goblins_current)

func on_crafting_heap_goblin_hired():
	crafting_heap_goblin_hired_total += 1
	crafting_heap_goblin_current += 1
	update_crafting_orcs_label.emit(crafting_heap_goblin_current)

func on_scrap_heap_goblin_fired():
	scrap_heap_goblins_current -= 1
	update_scrap_goblins_label.emit(scrap_heap_goblins_current)

func on_crafting_heap_goblin_fired():
	crafting_heap_goblin_current -= 1
	update_crafting_orcs_label.emit(crafting_heap_goblin_current)
