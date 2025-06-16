extends CanvasLayer

# Path to the JSON file containing dialogue data
@export var d_file: String = ""

@onready var dialogue_box = $Control/dialoguebox
@onready var chat_label = $Control/dialoguebox/chat
@onready var name_label = $Control/dialoguebox/name
@onready var Herr_Dahm = $"Control/dialoguebox/Herr Dahm"
@onready var timer = $Timer
@onready var typing_sound = $typing_sound

# Stores the parsed dialogue data from JSON
var dialogue = []
# Index to keep track of the current dialogue line
var current_dialogue_id = 0
# Flag to indicate whether the dialogue is currently active
var d_active = false



# Typing effect variables
var typing = false
var char_index = 0
var typing_speed = 0.03  # Speed at which characters appear in seconds

# Called when the node is added to the scene
func _ready():
	if d_active:
		return
	
	GlobalSignals.dialogue_start.connect(start)

# Starts the dialogue. Optionally takes a path to a dialogue file.
func start(dialogue_path: String = "") -> void:
	visible = true
	
	if dialogue_path != "":
		d_file = dialogue_path
	
	print("Dialogue START triggered. File path: ", d_file)
	
	# Ensure the file path is valid
	if d_file == "" or not FileAccess.file_exists(d_file):
		push_error(" Dialogue file not found: " + d_file)
		return
	
	# Load and parse the dialogue
	dialogue = load_dialogue()
	
	current_dialogue_id = -1
	d_active = true
	dialogue_box.visible = true
	$Overlay.visible = true
	
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
	if event.is_action_pressed("skip_cutscene"):
		d_active = false
		visible = false
		GlobalSignals.dialogue_finished.emit()
		return
	# Proceed or skip typing effect when 'ui_accept' (Enter/Space) is pressed
	if event.is_action_pressed("ui_accept"):
		if typing:
			# If still typing, instantly show the whole line
			typing_sound.stop()
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
		visible = false
		GlobalSignals.dialogue_finished.emit()
		return
		
	var entry = dialogue[current_dialogue_id]
	
	if typeof(entry) != TYPE_DICTIONARY:
		push_error("Invalid dialogue entry: " + str(entry))
		return
		
	# Get references to name and chat label
	
	# Set name and dialogue text from entry
	name_label.text = entry.get("name", "???")
	chat_label.text = entry.get("chat", "...")
	
	# Prepare typing effect
	char_index = 0
	chat_label.visible_characters = 0
	typing = true
	timer.start()
	Herr_Dahm.play("open")

# Typing effect: reveals characters one by one each frame
func _on_timer_timeout() -> void:
	if not typing: # if it´s not typing then stop the timer 
		Herr_Dahm.play("open")
		timer.stop()
		return

	char_index += 1 #else add a character every 0.05 seconds
	chat_label.visible_characters = char_index # update 

	if char_index <= chat_label.text.length(): 
		# if there are still characters left play sound 
		if not typing_sound.playing:
				typing_sound.play()
		#stop sound and typing when ther are no characters left
	if char_index >= chat_label.text.length():
		typing = false
		timer.stop()
		typing_sound.stop()
		Herr_Dahm.play("default")
