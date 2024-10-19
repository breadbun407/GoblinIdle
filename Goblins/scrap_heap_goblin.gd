extends Goblin

@onready var sprite: Sprite2D = $Sprite2D
@onready var bored_goblin_timer: Timer = $BoredGoblinTimer
@onready var fade_timer: Timer = $FadeTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var travel_component: TravelComponent = $TravelComponent

@export var scrap_block_scene: PackedScene
@export var speed = 400

var bored: bool = false

var scrap_heap_parent = null
var time_left: float = 0.0  # To store the remaining fade time
var original_alpha: float = 1.0  # To store the original alpha of the sprite

var state = STATE.BORED

func _ready() -> void:
	bored_goblin_timer.timeout.connect(on_bored_goblin_timer_timeout)
	fade_timer.timeout.connect(on_fade_timer_timeout)

	GoblinManager.scrap_heap_goblin_hired.emit()
	GoblinManager.parent_set_to_heap.connect(on_parent_set_to_heap)


func _process(delta: float) -> void:
	if state == STATE.BORED:
		animation_player.play("bored_anim")
		if travel_component.tween:
			travel_component.tween.kill()

func setup_travel(destination, home, item_to_carry, item_to_carry_scene):
	travel_component.destination = destination
	travel_component.home = home
	travel_component.item_to_carry = item_to_carry
	travel_component.item_to_carry_scene = item_to_carry_scene

func bored_goblin():
	bored = true
	var random_time_to_bored = randi_range(2, 10)
	bored_goblin_timer.one_shot = true
	bored_goblin_timer.start(random_time_to_bored)

	# Start modulating the sprite transparency over time
	modulate_transparency(random_time_to_bored)


func modulate_transparency(duration: float) -> void:
	time_left = duration
	original_alpha = sprite.modulate.a  # Get the current alpha value of the sprite

	# Start the fade timer
	fade_timer.wait_time = 0.1  # Adjust the rate of alpha reduction (every 0.1 seconds)
	fade_timer.one_shot = false
	fade_timer.start()


func on_fade_timer_timeout() -> void:
	if time_left > 0:
		# Reduce alpha over time
		sprite.modulate.a = original_alpha * (time_left / bored_goblin_timer.wait_time)
		time_left -= fade_timer.wait_time
	else:
		# When timer ends, set sprite fully transparent and stop the fade timer
		sprite.modulate.a = 0
		fade_timer.stop()


func on_bored_goblin_timer_timeout() -> void:
	if scrap_heap_parent == null:
		return
	GoblinManager.goblin_left_scrap_heap.emit(self, scrap_heap_parent)
	GoblinManager.scrap_heap_goblin_fired.emit()
	queue_free()

func on_parent_set_to_heap():
	var scrap_heap = get_tree().get_first_node_in_group("scrap_heap")
	var scrap_pile = scrap_heap_parent
	var item_to_carry = "Scrap"
	var item_to_carry_scene = scrap_block_scene
	setup_travel(scrap_pile, scrap_heap, item_to_carry, item_to_carry_scene)
	travel_component.begin_travel()
