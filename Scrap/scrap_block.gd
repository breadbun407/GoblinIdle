extends Node2D

@export var sprite_size: Vector2 = Vector2(1, 1)

func _ready() -> void:
	scale = sprite_size
