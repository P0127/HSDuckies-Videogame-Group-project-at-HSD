extends Node2D

@export var d_file: String  # Path to JSON dialogue file

var dialogue = []                # Loaded dialogue lines
var current_dialogue_id = -1     # Current dialogue index
var d_active = false             # Is dialogue active?

# Typewriter effect variables
var typing = false
var char_index = 0
var typing_speed = 0.03          # Seconds per character
var typing_timer = 0.0


func _ready():
	if d_active:
		return  # Skip if dialogue already started
	d_active = true
	$textbox.visible = true  # Show textbox
	start()


func start():
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()


func load_dialogue():
	# Load and parse JSON file
	if FileAccess.file_exists(d_file):
		var file = FileAccess.open(d_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return []


func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("ui_accept"):
		if typing:
			# If typing, show full text immediately
			$textbox/text.visible_characters = $textbox/text.text.length()
			typing = false
		else:
			# Go to next dialogue line
			next_script()


func next_script():
	current_dialogue_id += 1

	# End of dialogue
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$textbox.visible = false
		return

	# Set name and text from JSON
	$textbox/name.text = dialogue[current_dialogue_id]['name']
	$textbox/text.text = dialogue[current_dialogue_id]['text']

	
