extends Node2D
class_name TravelComponent

var goblin

var destination
var home
var travelling: bool = false
var item_to_carry
var carried_item
var carrying_item: bool = false

var available

var tween

var item_to_carry_scene

func _ready() -> void:
	travelling = true
	goblin = get_parent()

	GoblinManager.scrap_heap_goblin_hired.emit()
	GoblinManager.parent_set_to_heap.connect(on_parent_set_to_heap)
	ScrapManager.scrap_all_gone.connect(on_scrap_all_gone)

	GoblinManager.goblin_collected_scrap.connect(on_goblin_collected_scrap)
	GoblinManager.goblin_delivered_scrap.connect(on_goblin_delivered_scrap)

func _process(delta: float) -> void:
	if carrying_item:
		carried_item.position = Vector2(0, -100)

func move_toward_destination(target: Vector2):
	if available:
		# Calculate the distance between the goblin and the target
		var distance = global_position.distance_to(target)

		# Calculate the duration based on the distance and speed
		var duration = distance / goblin.speed

		# Use Tween to move the goblin to the target global_position at a consistent speed
		tween = create_tween()
		tween.tween_property(self, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

		# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
		tween.finished.connect(on_destination_tween_completed)

func on_destination_tween_completed():
	GoblinManager.goblin_collected_scrap.emit(self)
	var varied_position = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	var target = get_tree().get_first_node_in_group("scrap_heap").global_position + varied_position
	move_toward_home(target)

func move_toward_home(target):

	# Calculate the distance between the goblin and the target
	var distance = global_position.distance_to(target)

	# Calculate the duration based on the distance and speed
	var duration = distance / goblin.speed

	# Use Tween to move the goblin to the target global_position at a consistent speed
	tween = create_tween()
	tween.tween_property(self, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
	tween.finished.connect(on_home_tween_completed)

func on_home_tween_completed():
	GoblinManager.goblin_delivered_scrap.emit(self)


func on_parent_set_to_heap():
	var varied_position = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	move_toward_destination(destination.global_position + varied_position)

func on_scrap_all_gone():
	if carrying_item == false:
		available = true

func on_goblin_collected_scrap(goblin_node):
	if goblin_node == self:
		var item_to_carry_node = item_to_carry_scene.instantiate()
		add_child(item_to_carry_node)
		carrying_item = true
		carried_item = item_to_carry_node
		item_to_carry_node.position = Vector2(0, -100)

func on_goblin_delivered_scrap(goblin_node: Node):
	if goblin_node == self:
		if carrying_item:
			carrying_item = false
			carried_item.queue_free()
