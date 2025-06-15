extends Node2D

# Path to the JSON file containing dialogue data
@export var d_file: String = ""

# Signal emitted when the dialogue is finished
signal dialog_finished
signal dialog_started

# Stores the parsed dialogue data from JSON
var dialogue = []
# Index to keep track of the current dialogue line
var current_dialogue_id = 0
# Flag to indicate whether the dialogue is currently active
var d_active = false
# Reference to the player node (optional use)
var player

# Typing effect variables
var typing = false
var char_index = 0
var typing_speed = 0.03  # Speed at which characters appear in seconds

# Called when the node is added to the scene
func _ready():
	if d_active:
		return

	# Hide the dialogue UI elements at start
	$CanvasLayer/Control/dialoguebox.visible = false
	$Overlay.visible = false

# Starts the dialogue. Optionally takes a path to a dialogue file.
func start(dialogue_path: String = "") -> void:
	if dialogue_path != "":
		d_file = dialogue_path
	
	print("Dialogue START triggered. File path: ", d_file)

	# Ensure the file path is valid
	if d_file == "" or not FileAccess.file_exists(d_file):
		push_error(" Dialogue file not found: " + d_file)
		return

	# Get reference to the player (optional use)
	player = get_node_or_null("/root/Main/Player")

	# Load and parse the dialogue
	dialogue = load_dialogue()

	current_dialogue_id = -1
	d_active = true
	$CanvasLayer/Control/dialoguebox.visible = true
	$Overlay.visible = true
	
	# Disable player collision while dialogue is active
	if player:
		player.set_collision_enabled(false)  

	emit_signal("dialog_started")   # Signal hier aussenden
	
	next_script()

# Loads and parses the JSON dialogue file
func load_dialogue():
	if FileAccess.file_exists(d_file):
		print("Loading file:", d_file)
		var file = FileAccess.open(d_file, FileAccess.READ)
		var text = file.get_as_text()
		print("JSON content:\n", text)

		var json = JSON.new()
		var err = json.parse(text)
		if err != OK:
			push_error("Failed to parse JSON: " + text)
			return []

		print("Successfully parsed JSON:", json.data)
		return json.data
	else:
		push_error(" File does not exist: " + d_file)
	return []

# Handles player input during dialogue
func _input(event):
	if not d_active:
		return

	# Proceed or skip typing effect when 'ui_accept' (Enter/Space) is pressed
	if event.is_action_pressed("ui_accept"):
		if typing:
			# If still typing, instantly show the whole line
			var chat_label = $CanvasLayer/Control/dialoguebox.get_node("chat")
			chat_label.visible_characters = chat_label.text.length()
			typing = false
		else:
			# Otherwise go to the next line
			next_script()

# Shows the next dialogue line
func next_script():
	current_dialogue_id += 1

	# If end of dialogue is reached
	if current_dialogue_id >= dialogue.size():
		print("Dialogue finished.")
		d_active = false
		$CanvasLayer/Control/dialoguebox.visible = false
		$Overlay.visible = false
		
		
		# Kollision wieder aktivieren, wenn Dialog endet
		if player:
			player.set_collision_enabled(true)  
		emit_signal("dialog_finished")
		return

	var entry = dialogue[current_dialogue_id]
	if typeof(entry) != TYPE_DICTIONARY:
		push_error("Invalid dialogue entry: " + str(entry))
		return

	# Get references to name and chat labels
	var name_label = $CanvasLayer/Control/dialoguebox.get_node("name")
	var chat_label = $CanvasLayer/Control/dialoguebox.get_node("chat")
	
	# Set name and dialogue text from entry
	name_label.text = entry.get("name", "???")
	chat_label.text = entry.get("chat", "...")

	# Prepare typing effect
	char_index = 0
	chat_label.visible_characters = 0
	typing = true

# Typing effect: reveals characters one by one each frame
func _process(delta):
	if typing:
		var chat_label = $CanvasLayer/Control/dialoguebox.get_node("chat")
		
		# Increment character index based on time
		char_index += delta / typing_speed

		# When full line is shown, stop typing
		if char_index >= chat_label.text.length():
			chat_label.visible_characters = chat_label.text.length()
			typing = false
		else:
			# Otherwise show partial line
			chat_label.visible_characters = int(char_index)
