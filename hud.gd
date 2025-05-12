extends CanvasLayer

var ducks_collected = 0

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
	$StartButton.hide()
	$"Title Text".hide()
	start_game.emit()

func duck_collected_func():
	ducks_collected += 1
	$"Duck counter".text = "Ducks: " + str(ducks_collected)
