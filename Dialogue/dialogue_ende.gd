extends Node2D

@export var d_file: String  # Path to JSON dialogue file


# Node references
@onready var textbox = $textbox
@onready var textbox_name = $textbox/name
@onready var textbox_text = $textbox/text
@onready var typing_sound = $typing_sound
@onready var Herr_Dahm = $"Herr Dahm"
var dialogue = []   # Loaded dialogue lines
var current_dialogue_id = -1   # Current dialogue index
var d_active = false  

# Typewriter effect variables
var typing = false
var char_index = 0
var typing_speed = 0.05  # Seconds per character
var typing_timer = 0.0   # Timer for typewriter delay


func _ready():
	
	if d_active:
		return  # Skip if dialogue already started
	d_active = true
	textbox.visible = true  # Show textbox
	Herr_Dahm.play("open")
	Herr_Dahm.pause()
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
			# If typing, immediately show full text and stop sound
			textbox_text.visible_characters = textbox_text.text.length()
			typing = false
			typing_sound.stop()
		else:
			# Move to next dialogue line
			next_script()


func next_script():
	current_dialogue_id += 1

	# End of dialogue
	if current_dialogue_id >= len(dialogue):
		d_active = false
		textbox.visible = false
		return

	# Set name and text from JSON
	textbox_name.text = dialogue[current_dialogue_id]['name']
	textbox_text.text = dialogue[current_dialogue_id]['text']

	# Prepare typewriter effect
	char_index = 0
	typing_timer = 0.0
	textbox_text.visible_characters = 0
	typing = true


func _process(delta):
	if typing: #only if it's typing
		# Animation where mouth open
		Herr_Dahm.play("open")
		
		char_index += 1
		textbox_text.visible_characters = char_index 

			# Play sound for non-whitespace characters
		if char_index <= textbox_text.text.length():
				
			if not typing_sound.playing:
				typing_sound.play()

			# If line is fully shown, stop typing and sound
			if char_index >= textbox_text.text.length():
				typing = false
				typing_sound.stop()
				
	else :
					Herr_Dahm.play("default")  
