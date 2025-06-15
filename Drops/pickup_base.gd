extends Area2D

# Determines whether a dialogue should be shown when the player picks this up
@export var show_pickup_dialog: bool = true

# Called when the node is added to the scene
func _ready():
	# Called when the node is added to the scene
	connect("body_entered", Callable(self, "_on_body_entered"))

# Triggered when something enters the pickup area
func _on_body_entered(body: Node):
	# Only react if the entering body is the player
	if body.name != "Player":
		return

	# Get the current active scene (level)
	var level_1 = get_tree().get_current_scene()
	
	# Check if the pickup dialog should be shown
	if show_pickup_dialog and level_1 and level_1.has_variable("dialogue_begin_instance"):
		# Ensure the pickup dialog is only triggered once by checking and setting a flag in the current scene
		if not level_1.dialog_after_pickup_triggered:
			level_1.dialog_after_pickup_triggered = true		# Mark dialog as triggered to prevent repeats

		# Check if the dialogue instance exists in the current scene
		if level_1.dialogue_begin_instance:
			# Set the dialogue JSON file path
			level_1.dialogue_begin_instance.d_file = "res://Dialogue_cutscenes/ZwischenDialog_1.json"
			level_1.dialogue_begin_instance.start()		# Start the dialogue
	else:
		print("DEBUG: dialogue_begin_instance nicht vorhanden oder show_pickup_dialog ist false")
	
	# Pickup leicht verzögert löschen, damit kein zweiter sofort triggered
	await get_tree().create_timer(0.1).timeout
	queue_free()
