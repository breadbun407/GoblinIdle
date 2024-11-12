extends Node2D
class_name TravelComponent

var goblin

var destination
var home
var travelling: bool = false
var item_to_carry
var carried_item
var carrying_item: bool = false

var original_speed

var available

var tween

var item_to_carry_scene

func _ready() -> void:
	travelling = false
	available = true
	goblin = get_parent()
	ScrapManager.scrap_all_gone.connect(on_scrap_all_gone)

	GoblinManager.goblin_collected_item.connect(on_goblin_collected_item)
	GoblinManager.goblin_delivered_item.connect(on_goblin_delivered_item)
	original_speed = goblin.speed

func _process(delta: float) -> void:
	if carrying_item:
		carried_item.position = Vector2(0, -100)

func begin_travel():
	if available and destination != null:
		travelling = true
		move_toward_destination(destination.global_position)

func restart_travel():
	begin_travel()

func move_toward_destination(target: Vector2):
	if available:
		#print("Travelling to DESTINATION: " + str(destination))
		goblin.state = goblin.STATE.COLLECTING

		available = false
		# Calculate the distance between the goblin and the target
		var distance = goblin.global_position.distance_to(target)

		# Calculate the duration based on the distance and speed
		var duration = distance / goblin.speed

		update_sprite_direction(target)

		# Use Tween to move the goblin to the target global_position at a consistent speed
		tween = create_tween()
		tween.tween_property(goblin, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

		# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
		tween.finished.connect(on_destination_tween_completed)

func on_destination_tween_completed():
	if item_to_carry == "Scrap" and goblin is CraftingHeapGoblin:
		if ScrapManager.scrap_total <= 0:
			#print("NO SCRAP TO GRAB, BOSS")
			goblin.state = goblin.STATE.BORED
			goblin.check_collect_or_craft()
			return
	if item_to_carry == "Crafted_scrap_object" and goblin is CraftingHeapGoblin:
		if goblin.crafting_heap_parent.scrap_awaiting_crafting <= 0:
			#print("NO CRAFTED ITEMS TO GRAB, BOSS")
			goblin.state = goblin.STATE.BORED
			goblin.check_collect_or_craft()
			return
	GoblinManager.goblin_collected_item.emit(destination, item_to_carry, goblin)
	var varied_position = Vector2(randi_range(-80, 80), randi_range(-80, 80))
	var target = home.global_position + varied_position
	available = true
	move_toward_home(target)

func move_toward_home(target):
	if available:
		#print("Travelling to HOME: " + str(home))
		available = false
		goblin.state = goblin.STATE.DELIVERING
		# Calculate the distance between the goblin and the target
		var distance = goblin.global_position.distance_to(target)

		# Calculate the duration based on the distance and speed
		var duration = distance / goblin.speed

		update_sprite_direction(target)

		# Use Tween to move the goblin to the target global_position at a consistent speed
		tween = create_tween()
		tween.tween_property(goblin, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

		# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
		tween.finished.connect(on_home_tween_completed)

func on_home_tween_completed():
	if goblin is CraftingHeapGoblin and item_to_carry == "Crafted_scrap_object":
		if home is StorageHeap:
			home.display_scrap_item(carried_item)
	GoblinManager.goblin_delivered_item.emit(home, item_to_carry, goblin)
	goblin.state = goblin.STATE.BORED
	available = true
	if goblin is CraftingHeapGoblin:
		goblin.check_collect_or_craft()
	else:
		begin_travel()

func on_scrap_all_gone():
	if carrying_item == false and goblin is ScrapPileGoblin:
		available = true
		travelling = false
		goblin.state = goblin.STATE.BORED

func on_goblin_collected_item(from, item, goblin_node):
	if goblin_node == goblin:
		if not item_to_carry_scene:
			return
		var item_to_carry_node = item_to_carry_scene.instantiate()
		add_child(item_to_carry_node)
		carrying_item = true
		carried_item = item_to_carry_node
		item_to_carry_node.position = Vector2(0, -100)


func on_goblin_delivered_item(to, item, goblin_node):
	if goblin_node == goblin:
		if carrying_item:
			if item_to_carry == "Crafted_scrap_object" and goblin.state == goblin.STATE.DELIVERING:
				carrying_item = false
				carried_item.scale = Vector2(1.0, 1.0)
			else:
				carrying_item = false
				carried_item.queue_free()

func drop_item():
	#add animation for dropping item
	if carrying_item:
		carrying_item = false
		carried_item.queue_free()

func randomise_location():
	var varied_position = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	return varied_position

func update_sprite_direction(target_position: Vector2) -> void:
	# Get the direction of movement
	var direction = target_position - goblin.global_position

	# Flip all sprite nodes based on direction
	var flip = direction.x < 0
	for sprite in [goblin.goblin_walk, goblin.goblin_run, goblin.goblin_idle,
				  goblin.goblin_hit, goblin.goblin_death]:
		sprite.flip_h = flip
