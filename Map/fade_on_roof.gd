class_name fadeIN_and_fadeOut
extends Area2D

@onready var dach: TileMapLayer = $"../Dach_fade"

var fading_in: bool
var fading_out: bool

const fade_speed: float = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fading_in:
		dach.modulate.a += delta * fade_speed
		if dach.modulate.a >= 1.0:
			fading_in = false
	if fading_out:
		dach.modulate.a -= delta * fade_speed
		if dach.modulate.a <= 0.0:
			fading_out = false

@warning_ignore("unused_parameter")
func _check_fade(body: CharacterBody2D, entered: bool) -> void:
	if entered:
		fading_in = false
		fading_out = true
	else:
		fading_in = true
		fading_out = false

func _on_body_entered(body: Node2D) -> void:
	_check_fade(body, true)


func _on_body_exited(body: Node2D) -> void:
	_check_fade(body, false)
