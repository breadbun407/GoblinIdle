extends Node2D

@export var scrap_heap_goblin_scene: PackedScene
@export var cost_of_scrap = 2
@export var amount_of_scrap_purchase = 100

@onready var clickable_area_2d: Area2D = $ClickableArea2D
@onready var number_of_goblins_label: Label = %NumberOfGoblinsLabel
@onready var scrap_in_pile_label: Label = %ScrapInPileLabel
@onready var collect_scrap_timer: Timer = $CollectScrapTimer
@onready var goblin_layer: Node2D = $GoblinLayer
@onready var buy_scrap_button: Button = %BuyScrapButton


var scrap_in_pile = 0
var goblins_collecting_scrap = 0
var scrap_to_be_collected = 1
var total_scrap_collected = 0
var goblin_count = 1

var goblin_array: Array = []

func _ready() -> void:
	clickable_area_2d.input_event.connect(on_clickable_area_clicked)
	collect_scrap_timer.timeout.connect(on_collect_scrap_timer_timeout)
	buy_scrap_button.pressed.connect(on_buy_scrap_button_pressed)
	GoblinManager.goblin_left_scrap_heap.connect(on_goblin_left_scrap_heap)
	update_label()
	set_scrap_in_pile()

	GoblinManager.goblin_collected_scrap.connect(on_goblin_collected_scrap)
	GoblinManager.goblin_delivered_scrap.connect(on_goblin_delivered_scrap)

func _process(delta: float) -> void:
	update_label()
	if collect_scrap_timer.is_stopped() and scrap_in_pile >= 0:
		collect_scrap_timer.start()

	if scrap_in_pile <= 0:
		ScrapManager.scrap_all_gone.emit()
	else:
		GoblinManager.parent_set_to_heap.emit()

func update_label():
	number_of_goblins_label.text = str(goblins_collecting_scrap) + " goblins collecting scrap"
	scrap_in_pile_label.text = str(scrap_in_pile) + " scrap in pile"



func set_scrap_in_pile():
	var random_scrap_num = randi_range(5, 10)
	scrap_in_pile = random_scrap_num
	scrap_in_pile_label.text = str(scrap_in_pile) + " scrap in pile"


func on_goblin_delivered_scrap(goblin: Node):
	total_scrap_collected += scrap_to_be_collected
	ScrapManager.scrap_collected.emit(scrap_to_be_collected)



	if goblins_collecting_scrap > 0 and scrap_in_pile > 0:
		collect_scrap_timer.start()
	elif goblins_collecting_scrap > 0 and scrap_in_pile <= 0:
		goblins_not_collecting_scrap()

	update_label()

func on_goblin_collected_scrap(goblin):
	scrap_in_pile -= scrap_to_be_collected

#func collect_scrap():
	#if scrap_in_pile <= 0:
		#if goblins_collecting_scrap > 0:
			#goblins_not_collecting_scrap()
		#return
	#var scrap_to_be_collected = goblins_collecting_scrap
	#if scrap_in_pile > 0 and scrap_in_pile < scrap_to_be_collected:
		#scrap_to_be_collected = min(scrap_in_pile, scrap_to_be_collected)
#
	#total_scrap_collected += scrap_to_be_collected
	#ScrapManager.scrap_collected.emit(scrap_to_be_collected)
#
	#scrap_in_pile -= scrap_to_be_collected
#
	#if goblins_collecting_scrap > 0 and scrap_in_pile > 0:
		#collect_scrap_timer.start()
	#elif goblins_collecting_scrap > 0 and scrap_in_pile <= 0:
		#goblins_not_collecting_scrap()
	#update_label()

func goblins_not_collecting_scrap():
	for goblin in goblin_array:
		if goblin != null:
			pass
			#goblin.set_collecting_scrap(false)


func on_clickable_area_clicked(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("mouse_click"):
		ScrapManager.scrap_pile_clicked.emit(self)
		goblins_collecting_scrap += 1
		update_label()

		var scrap_heap_goblin = scrap_heap_goblin_scene.instantiate()
		goblin_layer.add_child(scrap_heap_goblin)
		scrap_heap_goblin.scale = Vector2(0.4, 0.4)
		randomise_position(scrap_heap_goblin)
		scrap_heap_goblin.name = "ScrapHeapGoblin" + str(goblin_count)
		goblin_count += 1

		goblin_array.append(scrap_heap_goblin)
		scrap_heap_goblin.scrap_heap_parent = self
		GoblinManager.parent_set_to_heap.emit()


func randomise_position(scrap_heap_goblin):
	var random_position = Vector2(randi_range(10, 80), randi_range(-80, 80))
	scrap_heap_goblin.position += random_position

func on_collect_scrap_timer_timeout():
	pass
	#collect_scrap()

func on_goblin_left_scrap_heap(goblin, scrap_heap_parent):
	if scrap_heap_parent == self:
		goblins_collecting_scrap -= 1
		goblin_array.erase(goblin)
	update_label()

func on_buy_scrap_button_pressed():
	if GoldManager.gold_total >= cost_of_scrap:
		GoldManager.gold_used.emit(cost_of_scrap)
		scrap_in_pile += amount_of_scrap_purchase
