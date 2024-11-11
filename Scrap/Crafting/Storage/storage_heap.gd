extends Node2D
class_name StorageHeap

@export var number_of_spots_for_objects = 15

var crafted_scrap_objects = 0

var spots = []

func _ready():
	setup_markers()

func setup_markers():
	var new_spot = Marker2D.new()
	add_child(new_spot)
	new_spot.position = Vector2(-90, -90)
	spots.append(new_spot)
	var position_offset = Vector2(20, 20)
	for spot in number_of_spots_for_objects:
		position_offset = Vector2(randi_range(-90, 90), randi_range(-90, 90))
		var next_spot = Marker2D.new()
		new_spot.add_child(next_spot)
		next_spot.position = position_offset
		spots.append(next_spot)


func remove_resource(amount, item):
	match item:
		"Scrap":
			pass
		"Crafted_scrap_object":
			crafted_scrap_objects -= amount
		_:
			print("Not an expected choice")


func add_resource(amount, item):
	match item:
		"Scrap":
			pass
		"Crafted_scrap_object":
			crafted_scrap_objects += amount
		_:
			print("Not an expected choice")

func display_scrap_item(new_item):
	var instanced_new_item = new_item.instantiate()
	add_child(instanced_new_item)
	#instanced_new_item.scale *= 0.9
	var random_index = randi_range(0, spots.size() - 1)
	var spot = spots.pop_at(random_index)
	if spot == null:
		print("NO SPOTS LEFT")
		GoblinManager.storage_full.emit(instanced_new_item)
		return
	instanced_new_item.position = spot.position
