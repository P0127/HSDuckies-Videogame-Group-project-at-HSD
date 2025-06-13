extends CanvasLayer

#handles HUD ingame

## VARIABLES
@onready var counter_letters = $"Counter/Duck counter letters"
@onready var counter_numbers = $"Counter/Duck counter digits"

## FUNCTIONS
func _ready() -> void:
	GlobalSignals.duck_collected_signal.connect(duck_collected_func)

#Adds Duck Counter in Bottom screen, which counts up on duck collected
func duck_collected_func():
	counter_letters.text = "Ducks: " 
	counter_numbers.text = str(GlobalSignals.duck_counter.ducks_collected)
