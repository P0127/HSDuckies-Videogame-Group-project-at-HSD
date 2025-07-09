class_name fadeIN_and_fadeOut
extends Area2D

@onready var dach: TileMapLayer = $"../Dach_fade"

var fading_in: bool
var fading_out: bool

var endScene_enabled : bool = false #Gets changed with a Signal

const fade_speed: float = 5.0 # controls the rate at which the fading occurs

#Connects to boss_slain Signal to enable dialogue once game is finnished
func _ready() -> void:
	GlobalSignals.boss_slain.connect(_set_endScene_flag)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fading_in:
		## the code increases the alpha (transparency) value of the dach element by adding delta * fade_speed to it
		dach.modulate.a += delta * fade_speed
		## once the alpha value reaches 1.0 (fully opaque), the fading_in flag is set to false
		if dach.modulate.a >= 1.0:
			fading_in = false
	if fading_out:
		## the code decreases the alpha value of the dach element by subtracting delta * fade_speed from it
		dach.modulate.a -= delta * fade_speed
		## once the alpha value reaches 0.0 (fully transparent), the fading_out flag is set to false
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

func _set_endScene_flag():
	endScene_enabled = true

func _on_body_entered(body: Node2D) -> void:
	_check_fade(body, true)
	if endScene_enabled:
		GlobalSignals.scene_controller.change_game_scene("res://CutScene/Dialogue_Ende.tscn")
		GlobalSignals.scene_controller.remove_gui()
		GlobalSignals.stop_sound.emit("level_sound")

func _on_body_exited(body: Node2D) -> void:
	_check_fade(body, false)
