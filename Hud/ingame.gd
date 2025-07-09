extends CanvasLayer

# Handles HUD ingame

## VARIABLES
@onready var counter_letters = $"HBoxContainer/Counter/Duck counter letters"
@onready var counter_numbers = $"HBoxContainer/Counter/Duck counter digits"

## FUNCTIONS
func _ready() -> void:
	GlobalSignals.duck_collected_signal.connect(duck_collected_func)
	# On default, only visible when paused (processed by Dialogue begin)
	$Dialogue_begin.visible = false

# Adds Duck Counter in bottom screen, which counts up on duck collected
func duck_collected_func():
	counter_letters.text = "Ducks: " 
	counter_numbers.text = str(GlobalSignals.duck_counter.ducks_collected)
