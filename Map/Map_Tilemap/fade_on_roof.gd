extends Area2D


const fade_speed: float = 5.0
var fading_in: bool
var fading_out: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fading_in:
		%Dach.modulate.a += delta * fade_speed
		if %Dach.modulate.a >= 1.0:
			fading_in = false
	if fading_out:
		%Dach.modulate.a -= delta * fade_speed
		if %Dach.modulate.a <= 0.0:
			fading_out = false


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
