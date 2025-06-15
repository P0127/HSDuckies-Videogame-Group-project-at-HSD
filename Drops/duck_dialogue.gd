extends Node

# Tracks how many ducks have been collected
var duck_counter := 0

# Flags to make sure each dialogue is only shown once
var halfway_dialog_shown := false
var final_dialog_shown := false

func _ready():
	# Connect to the global signal that is emitted whenever a duck is collected
	GlobalSignals.duck_collected_signal.connect(_on_duck_collected)

# Called whenever a duck is collected
func _on_duck_collected():
	duck_counter += 1
	print("DEBUG: Ducks collected: ", duck_counter)

	# Show halfway dialogue after collecting 10 ducks
	if duck_counter == 10 and not halfway_dialog_shown:
		halfway_dialog_shown = true
		_show_dialog("res://Dialogue_cutscenes/ZwischenDialog_2.json")

	# Show final dialogue after collecting 20 ducks
	elif duck_counter == 20 and not final_dialog_shown:
		final_dialog_shown = true
		_show_dialog("res://Dialogue_cutscenes/ZwischenDialog_3.json")

# Helper function to trigger dialogue via Dialogue_begin node
func _show_dialog(dialog_path: String):
	# Get the current scene from the scene tree
	var level_1 = get_tree().get_current_scene()
	
	# Check if the scene has a valid dialogue_begin_instance variable
	if level_1 and level_1.has_variable("dialogue_begin_instance") and level_1.dialogue_begin_instance:
		# Set the dialogue file and start the dialogue
		level_1.dialogue_begin_instance.d_file = dialog_path
		level_1.dialogue_begin_instance.start()
	else:
		print("DEBUG: dialogue_begin_instance nicht gefunden oder nicht vorhanden in Szene ", level_1)
