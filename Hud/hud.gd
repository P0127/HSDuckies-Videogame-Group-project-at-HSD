extends CanvasLayer

var ducks_collected = 0
@onready var start_button = $StartButton
@onready var start_button_animation = $StartButton/StartButtonAnimations
@onready var counter_letters = $"Counter/Duck counter letters"
@onready var counter_numbers = $"Counter/Duck counter digits"

# Notifies `Main` node that the button has been pressed
signal start_game



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.duck_collected_signal.connect(duck_collected_func)
	#made names longer for claritys
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed():
	# plays pressed animation
	start_button_animation.play("pressed")
	
	#delays hiding the button until animation finishes
	await start_button_animation.animation_finished

	
	start_button.hide()
	$"Title Text".hide()
	start_game.emit()

func duck_collected_func():
	ducks_collected += 1
	counter_letters.text = "Ducks: " 
	counter_numbers.text = str(ducks_collected)
	#devided into two labels so that the use of the custom font for numbers only 
	#would be possible
