extends Node2D

@export var scrap_heap_scene: PackedScene

var spawn_points: Array
@onready var scrap_pile_spawns: Node2D = $ScrapPileSpawns
@onready var scrap_heap_spawner_timer: Timer = $ScrapHeapSpawnerTimer
@onready var camera_2d: Camera2D = $Camera2D

var scrap_heap_count = 1

func _ready() -> void:
	var spawn_marker_array = scrap_pile_spawns.get_children()
	spawn_points = spawn_marker_array

	scrap_heap_spawner_timer.timeout.connect(on_scrap_heap_spawner_timer_timeout)
	get_viewport().size_changed.connect(_on_window_resized)
	update_camera()


func spawn_scrap():
	if !spawn_points:
		return
	var scrap_heap = scrap_heap_scene.instantiate()
	add_child(scrap_heap)
	scrap_heap.name = "ScrapHeap" + str(scrap_heap_count)
	scrap_heap_count += 1

	var random_index = randi_range(0, spawn_points.size() - 1)
	scrap_heap.global_position = spawn_points[random_index].global_position
	spawn_points.remove_at(random_index)

func on_scrap_heap_spawner_timer_timeout():
	spawn_scrap()

func _on_window_resized():
	update_camera()

func update_camera():
	# Get the current window size
	var window_size = get_viewport().get_visible_rect().size

	# Debugging: print the new window size
	print("Window resized to: ", window_size)

	# Update the camera zoom or adjust position based on new window size
	var base_resolution = Vector2(1280, 720) # Your desired base resolution
	camera_2d.zoom = window_size / base_resolution
