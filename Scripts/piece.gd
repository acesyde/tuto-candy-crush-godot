extends Node2D

class_name piece

export (String) var color;

# VARIABLES
var matched = false

# ON READY VAR
onready var move_tween: Tween = $move_tween
onready var sprite: Sprite = $Sprite

func move(target: Vector2) -> void:
	move_tween.interpolate_property(self, 
		"position",
		position, 
		target, 
		.3, 
		Tween.TRANS_ELASTIC, 
		Tween.EASE_OUT)
		
	move_tween.start()

func dim():
	sprite.modulate = Color(1.0, 1.0, 1.0, .5)
