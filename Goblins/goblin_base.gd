extends Node2D
class_name Goblin

@export var speed = 200.0

@onready var bored_goblin_timer: Timer = $BoredGoblinTimer
@onready var fade_timer: Timer = $FadeTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var goblin_walk: Sprite2D = $GoblinWalk
@onready var goblin_run: Sprite2D = $GoblinRun
@onready var goblin_idle: Sprite2D = $GoblinIdle
@onready var goblin_hit: Sprite2D = $GoblinHit
@onready var goblin_death: Sprite2D = $GoblinDeath

var time_left: float = 0.0  # To store the remaining fade time
var original_alpha: float = 1.0  # To store the original alpha of the sprite
var green_colour: float = 1
var blue_colour: float = 1
var fading: bool = false

enum STATE {COLLECTING, DELIVERING, BORED, WAITING}
var state = STATE.BORED
enum ANIMATION {WALKING, RUNNING, IDLING, WAITING}
var animation_state = null

var sprite_sheet_nodes: Array

func _ready() -> void:
	not_bored()

func walking():
	if animation_state != ANIMATION.WALKING:
		for node: Sprite2D in sprite_sheet_nodes:
			node.hide()
		goblin_walk.show()
		animation_player.stop()
		animation_player.play("goblin_walk")
		animation_state = ANIMATION.WALKING
		speed = speed * 2.0

func running():
	if animation_state != ANIMATION.RUNNING:
		for node in sprite_sheet_nodes:
			node.hide()
		goblin_run.show()
		animation_player.stop()
		animation_player.play("goblin_run")
		animation_state = ANIMATION.RUNNING
		speed = speed / 2.0

func idling():
	sprite_sheet_nodes = [
	goblin_walk,
	goblin_run,
	goblin_idle,
	goblin_hit,
	goblin_death
	]
	if animation_state != ANIMATION.IDLING:
		for node in sprite_sheet_nodes:
			node.hide()
		goblin_idle.show()
		animation_player.stop()
		animation_player.play("goblin_idle")
		animation_state = ANIMATION.IDLING

func waiting():
	if animation_state != ANIMATION.WAITING:
		for node in sprite_sheet_nodes:
			node.hide()
		goblin_hit.show()
		animation_player.stop()
		animation_player.play("goblin_hit")
		animation_state = ANIMATION.WAITING

func not_bored():
	bored_goblin_timer.stop()
	fade_timer.stop()
	set_material_up()
	fading = false

func bored_goblin():
	if state == STATE.BORED and fading == false and bored_goblin_timer.is_stopped():
		var random_time_to_bored = randi_range(2, 10)
		bored_goblin_timer.one_shot = true
		bored_goblin_timer.start(random_time_to_bored)

		# Start modulating the sprite transparency over time
		modulate_transparency(random_time_to_bored)
		fading = true


func modulate_transparency(duration: float) -> void:
	time_left = duration
	await get_tree().process_frame
	#original_alpha = goblin_idle.modulate.a  # Get the current alpha value of the sprite
	green_colour = goblin_idle.modulate.r
	blue_colour = goblin_idle.modulate.b

	# Start the fade timer
	fade_timer.wait_time = 0.1  # Adjust the rate of alpha reduction (every 0.1 seconds)
	fade_timer.one_shot = false
	fade_timer.start()


func on_fade_timer_timeout() -> void:
	if time_left > 0:
		# Reduce alpha over time

		var green = green_colour * (time_left / bored_goblin_timer.wait_time)
		var blue =  blue_colour * (time_left / bored_goblin_timer.wait_time)

		goblin_idle.material.set_shader_parameter("outline_colour", Color(1, blue, green, 1))

		time_left -= fade_timer.wait_time
	else:
		# When timer ends, set sprite fully transparent and stop the fade timer
		goblin_idle.modulate.r = 0
		goblin_idle.modulate.b = 0
		fade_timer.stop()

func set_material_up():
	var mat: Material = goblin_idle.material
	mat.resource_local_to_scene = true
	goblin_idle.material.set_shader_parameter("outline_colour", Color(1, 1, 1, 1))
	pass
