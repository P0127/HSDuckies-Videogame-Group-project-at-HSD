extends Node2D

@export var d_file: String  # Path to JSON dialogue file


# Node references
@onready var textbox = $textbox
@onready var textbox_name = $textbox/name
@onready var textbox_text = $textbox/text
@onready var typing_sound = $typing_sound
@onready var Herr_Dahm = $"Herr Dahm"
@onready var timer = $Timer
var dialogue = []   # Loaded dialogue lines
var current_dialogue_id = -1   # Current dialogue index
var d_active = false  

# Typewriter effect variables
var typing = false
var char_index = 0


func _ready():
	#starts scene with a black fade in
	$fade_in/AnimationPlayer.play("fade_in")

#starts dialogue after the fade in is done
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if d_active:
		return  # Skip if dialogue already started
	d_active = true
	textbox.visible = true  # Show textbox
	
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
	textbox_text.visible_characters = 0
	typing = true
	timer.start()
	Herr_Dahm.play("open")





func _on_timer_timeout() -> void:
	if not typing: # if it´s not typing then stop the timer 
		Herr_Dahm.play("open")
		timer.stop()
		return

	char_index += 1 #else add a character every 0.05 seconds
	textbox_text.visible_characters = char_index # update 

	if char_index <= textbox_text.text.length(): 
		# if there are still characters left play sound 
		if not typing_sound.playing:
				typing_sound.play()
		#stop sound and typing when ther are no characters left
	if char_index >= textbox_text.text.length():
		typing = false
		timer.stop()
		typing_sound.stop()
		Herr_Dahm.play("default")
	
