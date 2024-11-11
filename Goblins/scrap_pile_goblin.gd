extends Goblin
class_name ScrapPileGoblin

@onready var travel_component: TravelComponent = $TravelComponent
@export var scrap_block_scene: PackedScene

var scrap_heap_parent = null

func _ready() -> void:
	super()
	idling()
	bored_goblin_timer.timeout.connect(on_bored_goblin_timer_timeout)
	fade_timer.timeout.connect(on_fade_timer_timeout)

	GoblinManager.scrap_heap_goblin_hired.emit()
	GoblinManager.parent_set_to_heap.connect(on_parent_set_to_heap)
	GoblinManager.scrap_pile_goblin_check_travel.connect(go_travel)
	set_material_up()

func _process(delta: float) -> void:
	if state == STATE.BORED:
		bored_goblin()
		idling()
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
	if scrap_heap_parent == null:
		return
	GoblinManager.goblin_left_scrap_heap.emit(self, scrap_heap_parent)
	GoblinManager.scrap_heap_goblin_fired.emit()
	queue_free()

func go_travel():
	var scrap_pile = scrap_heap_parent
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	var item_to_carry = "Scrap"
	var item_to_carry_scene = scrap_block_scene
	setup_travel(scrap_pile, scrap_heap, item_to_carry, item_to_carry_scene)
	travel_component.begin_travel()

func on_parent_set_to_heap(goblin):
	if goblin == self:
		var scrap_pile = scrap_heap_parent
		var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
		var item_to_carry = "Scrap"
		var item_to_carry_scene = scrap_block_scene
		setup_travel(scrap_pile, scrap_heap, item_to_carry, item_to_carry_scene)
		travel_component.begin_travel()
