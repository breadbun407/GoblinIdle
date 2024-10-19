extends Node2D

@export var crafting_heap_goblin_scene: PackedScene
@export var crafted_scrap_object_scene: PackedScene


@onready var clickable_area_2d: Area2D = $ClickableArea2D
@onready var number_of_goblins_label: Label = %NumberOfGoblinsLabel
@onready var number_of_crafted_objects_label: Label = %NumberOfCraftedObjectsLabel
@onready var scrap_to_be_used_label: Label = %ScrapToBeUsedLabel
@onready var crafting_scrap_timer: Timer = $CraftingScrapTimer
@onready var goblin_layer: Node2D = $GoblinLayer
@onready var storage_heap: Node2D = $StorageHeap

var crafting_goblins = 0
var crafted_objects = 0

var scrap_awaiting_crafting = 0

var total_crafted_objects = 0
var goblin_count = 1

var goblin_array: Array = []

func _ready() -> void:
	clickable_area_2d.input_event.connect(on_clickable_area_clicked)
	crafting_scrap_timer.timeout.connect(on_crafting_scrap_timer_timeout)
	GoblinManager.goblin_left_crafting_heap.connect(on_goblin_left_crafting_heap)
	ScrapManager.update_scrap_in_crafting_heap.connect(on_scrap_total_updated)
	update_label()
	set_scrap_awaiting_crafting()

func _process(delta: float) -> void:
	if crafting_scrap_timer.is_stopped() and scrap_awaiting_crafting >= 0:
		crafting_scrap_timer.start()

func on_clickable_area_clicked(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("mouse_click"):
		ScrapManager.scrap_pile_clicked.emit(self)
		crafting_goblins += 1
		update_label()

		var crafting_heap_goblin = crafting_heap_goblin_scene.instantiate()
		goblin_layer.add_child(crafting_heap_goblin)
		crafting_heap_goblin.scale = Vector2(0.4, 0.4)
		randomise_position(crafting_heap_goblin)
		crafting_heap_goblin.name = "ScrapHeapGoblin" + str(goblin_count)
		goblin_count += 1

		goblin_array.append(crafting_heap_goblin)
		crafting_heap_goblin.crafting_heap_parent = self

func update_label():
	number_of_goblins_label.text = str(crafting_goblins) + " goblins crafting scrap objects"
	number_of_crafted_objects_label.text = str(crafted_objects) + " crafted objects in storage"
	scrap_to_be_used_label.text = str(scrap_awaiting_crafting) + " scrap awaiting use"


func set_scrap_awaiting_crafting():
	scrap_awaiting_crafting = ScrapManager.scrap_total
	scrap_to_be_used_label.text = str(scrap_awaiting_crafting) + " scrap awaiting use"

func on_scrap_total_updated(amount):
	var scarp_heap_scrap_value = amount
	scrap_awaiting_crafting = amount
	scrap_to_be_used_label.text = str(scarp_heap_scrap_value) + " scrap awaiting use"

func craft_scrap_object():
	if scrap_awaiting_crafting <= 0:
		if crafting_goblins > 0:
			goblins_not_crafting_objects()
		return
	var scrap_to_be_crafted = crafting_goblins
	#print("Scrap to be collected: " + str(scrap_to_be_crafted))

	if scrap_awaiting_crafting > 0 and scrap_awaiting_crafting < scrap_to_be_crafted:
		scrap_to_be_crafted = min(scrap_awaiting_crafting, scrap_to_be_crafted)
		print("Scrap to be collected: " + str(scrap_to_be_crafted))

	total_crafted_objects += scrap_to_be_crafted
	crafted_objects += scrap_to_be_crafted

	scrap_awaiting_crafting -= scrap_to_be_crafted
	ScrapManager.scrap_used.emit(scrap_to_be_crafted)

	if crafting_goblins > 0 and scrap_awaiting_crafting > 0:
		crafting_scrap_timer.start()
	elif crafting_goblins > 0 and scrap_awaiting_crafting <= 0:
		goblins_not_crafting_objects()
	update_label()

func goblins_not_crafting_objects():
	for goblin in goblin_array:
		if goblin != null:
			goblin.set_crafting_scrap_object(false)


func randomise_position(crafting_heap_goblin):
	var random_position = Vector2(randi_range(10, 80), randi_range(-80, 80))
	crafting_heap_goblin.position += random_position

func on_crafting_scrap_timer_timeout():
	craft_scrap_object()

func on_goblin_left_crafting_heap(goblin, crafting_heap_parent):
	if crafting_heap_parent == self:
		crafting_goblins -= 1
		goblin_array.erase(goblin)
	update_label()

func generate_crafted_item():
	var crafted_scrap_object = crafted_scrap_object_scene.instantiate()
	storage_heap.add_child(crafted_scrap_object)
