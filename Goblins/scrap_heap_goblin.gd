extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var bored_goblin_timer: Timer = $BoredGoblinTimer
@onready var fade_timer: Timer = $FadeTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var scrap_block_scene: PackedScene
@export var speed = 100


var collecting_scrap: bool = false
var bored: bool = false

var scrap_heap_parent = null
var time_left: float = 0.0  # To store the remaining fade time
var original_alpha: float = 1.0  # To store the original alpha of the sprite

enum STATE {COLLECTING_SCRAP, DELIVERING_SCRAP, BORED}
var state = STATE.BORED

var tween

var carried_scrap = null
var carrying_scrap = false


func _ready() -> void:
	collecting_scrap = true
	bored_goblin_timer.timeout.connect(on_bored_goblin_timer_timeout)
	fade_timer.timeout.connect(on_fade_timer_timeout)

	GoblinManager.scrap_heap_goblin_hired.emit()
	GoblinManager.parent_set_to_heap.connect(on_parent_set_to_heap)
	ScrapManager.scrap_all_gone.connect(on_scrap_all_gone)

	GoblinManager.goblin_collected_scrap.connect(on_goblin_collected_scrap)
	GoblinManager.goblin_delivered_scrap.connect(on_goblin_delivered_scrap)

func _process(delta: float) -> void:
	if state == STATE.BORED:
		animation_player.play("bored_anim")
		if tween:
			tween.kill()

	if carrying_scrap:
		carried_scrap.position = Vector2(0, -100)

func move_toward_scrap_pile(target: Vector2):
	if state == STATE.BORED:
		if scrap_heap_parent.scrap_in_pile > 0 or carrying_scrap == true:
			bored_goblin_timer.stop()
			fade_timer.stop()
			sprite.modulate.a = 1
			bored = false
			# Calculate the distance between the goblin and the target
			var distance = global_position.distance_to(target)

			# Calculate the duration based on the distance and speed
			var duration = distance / speed

			# Use Tween to move the goblin to the target global_position at a consistent speed
			tween = create_tween()
			tween.tween_property(self, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			state = STATE.COLLECTING_SCRAP

			# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
			tween.finished.connect(on_scrap_pile_tween_completed)

func on_scrap_pile_tween_completed():
	GoblinManager.goblin_collected_scrap.emit(self)
	var varied_position = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	var target = get_tree().get_first_node_in_group("scrap_heap").global_position + varied_position
	move_toward_scrap_heap(target)

func move_toward_scrap_heap(target):
	if state == STATE.COLLECTING_SCRAP:

	# Calculate the distance between the goblin and the target
		var distance = global_position.distance_to(target)

		# Calculate the duration based on the distance and speed
		var duration = distance / speed

		# Use Tween to move the goblin to the target global_position at a consistent speed
		tween = create_tween()
		tween.tween_property(self, "global_position", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		state = STATE.DELIVERING_SCRAP

		# Optionally, you can connect the tween_completed signal if you want to trigger something after the move.
		tween.finished.connect(on_scrap_heap_tween_completed)

func on_scrap_heap_tween_completed():
	GoblinManager.goblin_delivered_scrap.emit(self)
	state = STATE.BORED
	if scrap_heap_parent:
		on_parent_set_to_heap()

func set_collecting_scrap(is_collecting_scrap):
	if not is_collecting_scrap and bored == false:
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
	if scrap_heap_parent == null:
		return
	GoblinManager.goblin_left_scrap_heap.emit(self, scrap_heap_parent)
	GoblinManager.scrap_heap_goblin_fired.emit()
	queue_free()

func on_parent_set_to_heap():
	var varied_position = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	move_toward_scrap_pile(scrap_heap_parent.global_position + varied_position)

func on_scrap_all_gone():
	if carrying_scrap == false:
		state = STATE.BORED

func on_goblin_collected_scrap(goblin):
	if goblin == self:
		var scrap_block = scrap_block_scene.instantiate()
		add_child(scrap_block)
		carrying_scrap = true
		carried_scrap = scrap_block
		scrap_block.position = Vector2(0, -100)

func on_goblin_delivered_scrap(goblin: Node):
	if goblin == self:
		if carrying_scrap:
			carrying_scrap = false
			carried_scrap.queue_free()
