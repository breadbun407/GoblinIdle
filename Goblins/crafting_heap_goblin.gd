extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var bored_goblin_timer: Timer = $BoredGoblinTimer
@onready var fade_timer: Timer = $FadeTimer


var crafting_scrap_object: bool = false
var bored: bool = false

var crafting_heap_parent = null
var time_left: float = 0.0  # To store the remaining fade time
var original_alpha: float = 1.0  # To store the original alpha of the sprite

func _ready() -> void:
	crafting_scrap_object = true
	bored_goblin_timer.timeout.connect(on_bored_goblin_timer_timeout)
	fade_timer.timeout.connect(on_fade_timer_timeout)

	GoblinManager.crafting_heap_goblin_hired.emit()

func set_crafting_scrap_object(is_crafting_scrap_object):
	if not is_crafting_scrap_object and bored == false:
		bored_goblin()

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
	if crafting_heap_parent == null:
		return
	GoblinManager.goblin_left_crafting_heap.emit(self, crafting_heap_parent)
	GoblinManager.crafting_heap_goblin_fired.emit()
	queue_free()
