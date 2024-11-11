extends Node2D

@export var crafting_heap_goblin_scene: PackedScene
@export var crafted_scrap_object_scene: PackedScene


@onready var clickable_area_2d: Area2D = $ClickableArea2D
@onready var number_of_goblins_label: Label = %NumberOfGoblinsLabel
@onready var number_of_crafted_objects_label: Label = %NumberOfCraftedObjectsLabel
@onready var scrap_to_be_used_label: Label = %ScrapToBeUsedLabel
@onready var goblin_layer: Node2D = $GoblinLayer
@onready var storage_heap: Node2D = $StorageHeap

var crafting_goblins = 0
var crafted_objects = 0

var scrap_awaiting_crafting = 0

var total_crafted_objects = 0
var goblin_count = 1

func _ready() -> void:
	clickable_area_2d.input_event.connect(on_clickable_area_clicked)
	GoblinManager.goblin_left_crafting_heap.connect(on_goblin_left_crafting_heap)

	update_label()

func remove_resource(amount, item):
	match item:
		"Scrap":
			pass
		"Crafted_scrap_object":
			scrap_awaiting_crafting -= amount
			GoblinManager.crafting_goblin_check_craft.emit()
			#print("remove crafted scrap object")
		_:
			print("Not an expected choice")
	update_label()

func add_resource(amount, item):
	match item:
		"Scrap":
			scrap_awaiting_crafting += amount
			GoblinManager.crafting_goblin_check_craft.emit()
		"Crafted_scrap_object":
			#print("add crafted scrap object")
			pass
		_:
			print("Not an expected choice")
	update_label()

func on_clickable_area_clicked(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("mouse_click"):
		ScrapManager.scrap_pile_clicked.emit(self)
		crafting_goblins += 1
		update_label()

		var crafting_heap_goblin = crafting_heap_goblin_scene.instantiate()
		goblin_layer.add_child(crafting_heap_goblin)
		crafting_heap_goblin.scale = Vector2(0.4, 0.4)
		randomise_position(crafting_heap_goblin)
		crafting_heap_goblin.name = "CraftingHeapGoblin" + str(goblin_count)
		goblin_count += 1

		crafting_heap_goblin.crafting_heap_parent = self
		GoblinManager.parent_set_to_heap.emit(crafting_heap_goblin)

func update_label():
	number_of_goblins_label.text = str(crafting_goblins) + " goblins crafting scrap objects"
	number_of_crafted_objects_label.text = str(crafted_objects) + " crafted objects in storage"
	scrap_to_be_used_label.text = str(scrap_awaiting_crafting) + " scrap awaiting use"

func randomise_position(crafting_heap_goblin):
	var random_position = Vector2(randi_range(10, 80), randi_range(-80, 80))
	crafting_heap_goblin.position += random_position

func on_goblin_left_crafting_heap(goblin, crafting_heap_parent):
	if crafting_heap_parent == self:
		crafting_goblins -= 1
	update_label()

func generate_crafted_item():
	var crafted_scrap_object = crafted_scrap_object_scene.instantiate()
	storage_heap.add_child(crafted_scrap_object)
