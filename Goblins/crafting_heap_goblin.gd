extends Goblin
class_name CraftingHeapGoblin

@export var scrap_block_scene: PackedScene

@onready var travel_component: TravelComponent = $TravelComponent

var crafting_scrap_object: bool = false
var crafting_heap_parent = null

func _ready() -> void:
	super()
	idling()
	crafting_scrap_object = true
	bored_goblin_timer.timeout.connect(on_bored_goblin_timer_timeout)
	fade_timer.timeout.connect(on_fade_timer_timeout)
	GoblinManager.crafting_heap_goblin_hired.emit()
	GoblinManager.parent_set_to_heap.connect(on_parent_set_to_heap)
	GoblinManager.crafting_goblin_check_craft.connect(check_collect_or_craft)
	GoblinManager.storage_full.connect(on_storage_full)

	# Add signal to check when scrap total changes
	ScrapManager.scrap_total_changed.connect(on_scrap_total_changed)

func _process(delta: float) -> void:
	if state == STATE.BORED:
		bored_goblin()
		idling()
		travel_component.available = true
		speed = travel_component.original_speed
		if travel_component.tween:
			travel_component.tween.kill()
		check_collect_or_craft()
	elif state == STATE.WAITING:
		waiting()
		not_bored()
		if travel_component.tween:
			travel_component.tween.kill()
	elif state == STATE.COLLECTING:
		running()
		not_bored()
	elif state == STATE.DELIVERING:
		walking()
		not_bored()


func setup_travel(destination, home, item_to_carry, item_to_carry_scene):
	travel_component.destination = destination
	travel_component.home = home
	travel_component.item_to_carry = item_to_carry
	travel_component.item_to_carry_scene = item_to_carry_scene

func on_bored_goblin_timer_timeout() -> void:
	if crafting_heap_parent == null:
		return
	GoblinManager.goblin_left_crafting_heap.emit(self, crafting_heap_parent)
	GoblinManager.crafting_heap_goblin_fired.emit()
	queue_free()

func check_collect_or_craft():
	if state == STATE.WAITING:
		return
	if crafting_heap_parent:
		if travel_component.available:
			set_travel_logic()

func on_parent_set_to_heap(goblin):
	if goblin == self:
		set_travel_logic()

func set_travel_logic():
	var crafting_heap = crafting_heap_parent
	var collected_scrap = ScrapManager.scrap_total
	var scrap_in_crafting_heap = crafting_heap_parent.scrap_awaiting_crafting
	# Always check current scrap total before deciding where to go
	if collected_scrap <= 0 and scrap_in_crafting_heap > 0:
		# When no scrap available but we have scrap to craft
		var storage_heap = crafting_heap_parent.storage_heap
		var item_to_carry = "Crafted_scrap_object"
		var item_to_carry_scene = crafting_heap_parent.crafted_scrap_object_scene
		setup_travel(crafting_heap, storage_heap, item_to_carry, item_to_carry_scene)
		if travel_component.available:
			travel_component.begin_travel()
	elif collected_scrap > 0:
		if scrap_in_crafting_heap > 5:
			var storage_heap = crafting_heap_parent.storage_heap
			var item_to_carry = "Crafted_scrap_object"
			var item_to_carry_scene = crafting_heap_parent.crafted_scrap_object_scene
			setup_travel(crafting_heap, storage_heap, item_to_carry, item_to_carry_scene)
			if travel_component.available:
				travel_component.begin_travel()
		else:
			# When scrap is available and we need more
			var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
			var item_to_carry = "Scrap"
			var item_to_carry_scene = scrap_block_scene
			setup_travel(scrap_heap, crafting_heap, item_to_carry, item_to_carry_scene)
			if travel_component.available:
				travel_component.begin_travel()

func on_scrap_total_changed(new_total):
	if new_total <= 0 and state != STATE.DELIVERING:
		check_collect_or_craft()

func on_storage_full(item):
	if travel_component.carrying_item and travel_component.item_to_carry == "Crafted_scrap_object":
		state = STATE.WAITING
		travel_component.available = false
		var too_long_to_wait_timer = Timer.new()
		too_long_to_wait_timer.wait_time = 2.0
		too_long_to_wait_timer.one_shot = true
		too_long_to_wait_timer.timeout.connect(got_bored_waiting)

func got_bored_waiting():
	print("bored")
	travel_component.drop_item()
	state = STATE.BORED
