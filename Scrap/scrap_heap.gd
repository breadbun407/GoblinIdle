extends Node2D

@export var scrap_block_scene: PackedScene

@export var amount_of_scrap_to_sell = 5
@export var value_of_sold_scrap = 10

@onready var scrap_total_label: Label = %ScrapTotalLabel
@onready var scrap_block_layer: Node2D = $ScrapBlockLayer
@onready var sell_scrap_button: Button = %SellScrapButton
@onready var gold_total_label: Label = %GoldTotalLabel

var scrap_block_array = []


func _ready() -> void:
	ScrapManager.scrap_collected.connect(on_scrap_collected)
	scrap_total_label.text = "Scrap: " + str(ScrapManager.scrap_total)
	ScrapManager.add_scrap_to_hoard.connect(add_scrap_to_hoard)
	ScrapManager.remove_scrap_from_hoard.connect(remove_scrap_from_hoard)
	sell_scrap_button.pressed.connect(on_sell_scrap_button_pressed)
	update_label_text()



func update_label_text():
	scrap_total_label.text = "Scrap: " + str(ScrapManager.scrap_total)
	gold_total_label.text = "Gold: " + str(GoldManager.gold_total)


func on_scrap_collected(scrap_collected_amount):
	update_label_text()

func add_scrap_to_hoard(amount_to_add):
	for value in amount_to_add:
		var scrap_block = scrap_block_scene.instantiate()
		scrap_block_layer.add_child(scrap_block)
		scrap_block.position += Vector2(randi_range(-50, 50), randi_range(-50, 50))

		scrap_block_array.append(scrap_block)

func remove_scrap_from_hoard(amount_to_remove):
	for value in amount_to_remove:
		scrap_block_array[0].queue_free()
		scrap_block_array.remove_at(0)

func on_sell_scrap_button_pressed():
	if ScrapManager.scrap_total >= amount_of_scrap_to_sell:
		GoldManager.gold_gained.emit(value_of_sold_scrap)
		ScrapManager.scrap_used.emit(amount_of_scrap_to_sell)
		update_label_text()