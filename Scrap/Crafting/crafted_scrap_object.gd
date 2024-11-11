extends Node2D
class_name CraftedScrapObject

@onready var sprite: Sprite2D = $Sprite2D
@onready var quality_label: Label = %QualityLabel
@onready var price_label: Label = %PriceLabel
@onready var on_hover_area_2d: Area2D = $OnHoverArea2D
@onready var labels_panel: Panel = %LabelsPanel

var labels_showing: bool = false
var quality
var price

var icons = [
	"res://Icons/CraftingIcons/barbed-spear.png",
	"res://Icons/CraftingIcons/bone-knife (1).png",
	"res://Icons/CraftingIcons/bone-knife.png",
	"res://Icons/CraftingIcons/bone-mace.png",
	"res://Icons/CraftingIcons/clay-brick.png",
	"res://Icons/CraftingIcons/fur-shirt.png",
	"res://Icons/CraftingIcons/spine-arrow.png",
	"res://Icons/CraftingIcons/stone-axe.png",
	"res://Icons/CraftingIcons/stone-spear.png",
	"res://Icons/CraftingIcons/stone-wheel.png",
	"res://Icons/CraftingIcons/tribal-pendant.png",
	"res://Icons/CraftingIcons/wood-canoe.png",
	"res://Icons/CraftingIcons/wood-club.png",
	"res://Icons/CraftingIcons/wood-stick.png"
]

var qualities = [
	"shoddy",
	"fine",
	"legendary"
]

func _ready() -> void:
	on_hover_area_2d.mouse_entered.connect(on_mouse_entered)
	on_hover_area_2d.mouse_exited.connect(on_mouse_exited)
	var random_index = randi_range(0, icons.size() - 1)
	var chosen_icon = icons[random_index]
	sprite.texture = load(chosen_icon)

	quality = set_quality()
	price = set_price(quality)
	update_label(quality, price)

func _process(delta: float) -> void:
	if labels_showing:
		if Input.is_action_just_pressed("mouse_click"):
			sell_item()


func update_label(chosen_quality, chosen_price):
	quality_label.text = str(chosen_quality)
	price_label.text = str(chosen_price)

func set_quality():
	var random_index = randi_range(0, qualities.size() - 1)
	return qualities[random_index]

func set_price(chosen_quality):
	var random_price = randi_range(0, 5)
	var price_multiplier = 0
	match chosen_quality:
		"shoddy":
			price_multiplier = 0.5
		"fine":
			price_multiplier = 1.2
		"legendary":
			price_multiplier = 3
	var chosen_price = random_price * price_multiplier
	return max(floor(chosen_price), 1)

func sell_item():
	GoldManager.gold_gained.emit(price)
	StorageManager.clear_hovered_item()
	queue_free()

func on_mouse_entered():
	if StorageManager.current_hovered_item != self:
		StorageManager.set_hovered_item(self)
		show_labels()

func on_mouse_exited():
	if StorageManager.current_hovered_item == self:
		StorageManager.clear_hovered_item()

# Show the labels and update label state
func show_labels():
	labels_panel.show()
	labels_showing = true
	z_index += 1

# Hide the labels and reset label state
func hide_labels():
	labels_panel.hide()
	labels_showing = false
	z_index -= 1
