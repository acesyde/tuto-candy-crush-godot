extends Node2D

class_name piece

export (String) var color;

onready var move_tween: Tween = $move_tween

func move(target: Vector2) -> void:
	move_tween.interpolate_property(self, 
		"position",
		position, 
		target, 
		.3, 
		Tween.TRANS_ELASTIC, 
		Tween.EASE_OUT)
		
	move_tween.start()
