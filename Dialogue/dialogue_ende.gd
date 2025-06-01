extends Node2D


@export var d_file: String  # JSON dialogue file path

var dialogue = []           # Loaded dialogue lines
var current_dialogue_id = 0 # Current dialogue index
var d_active = false        # Dialogue active flag




func _ready():
	if d_active: 
		return     # Skip if already active
	d_active = true
	$textbox.visible = true # Show textbox
	start()                 # Begin dialogue

func start():
	dialogue = load_dialogue() 
	current_dialogue_id = -1 # Set before first line
	next_script()            # Show first line

func load_dialogue():
	if FileAccess.file_exists(d_file):
		var file = FileAccess.open(d_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text()) # Parse JSON
	return []

func _input(event):
	if not d_active: 
		return
	if event.is_action_pressed("ui_accept"): # On confirm key for example space 
		next_script()   # Next dialogue line

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue): # End of dialogue
		d_active = false
		$textbox.visible = false
		return
	$textbox/name.text = dialogue[current_dialogue_id]['name'] # Show name
	$textbox/text.text = dialogue[current_dialogue_id]['text'] # Show text
	
	
