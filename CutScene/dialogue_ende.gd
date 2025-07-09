extends Node2D

@export var d_file: String  # Path to JSON dialogue file


## Node references
@onready var textbox = $textbox
@onready var textbox_name = $textbox/name
@onready var textbox_text = $textbox/text
@onready var Herr_Dahm = $"Herr Dahm"
@onready var timer = $Timer

## dialogue variables
var dialogue = []   # Loaded dialogue lines
var current_dialogue_id = -1   # Current dialogue index
var d_active = false  
var dialogue_done := false # Deactivates input event upon dialogue end

## Typewriter effect variables
var typing = false
var char_index = 0

#Called when the node enters the scene tree for the first time.
func _ready():
	#starts scene with a black fade in
	$fade_in/AnimationPlayer.play("fade_in")

#starts dialogue after the fade in is done
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		#At the start
		"fade_in":
			if d_active:
				return  # Skip if dialogue already started
			d_active = true
			textbox.visible = true  # Show textbox
			
			start()
		#Triggered at Dialogue end, after fade to black; switches to main menue
		"RESET":
			GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")

# starts the dialogue sequence. 
func start():
	dialogue = load_dialogue() # loads the dialogue from the JSON file
	current_dialogue_id = -1 #resets the dialogue index
	Herr_Dahm.play("open") #plays the starting animation
	next_script()  #moves to the first dialogue line

# loads the dialogue data from the specified JSON file.
func load_dialogue():
	# Loads and parses JSON file
	if FileAccess.file_exists(d_file): #If the file exists
		#reads and parses the JSON content
		var file = FileAccess.open(d_file, FileAccess.READ) 
		return JSON.parse_string(file.get_as_text())
	return [] #Otherwise, it returns an empty array

#handles player input during the dialogue sequence.
func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("skip_cutscene"): # allows to skip 
		$fade_in/AnimationPlayer.play("RESET") # Resets fade-in animation
		dialogue_done = true # Marks dialogue as finished
		set_process_input(false) # Disables further input
		GlobalSignals.stop_sound.emit("typing_sound")  # Stops typing sound effect
		return
	# If dialogue is still ongoing (not finished)
	if not dialogue_done:
		if event.is_action_pressed("ui_accept"):  # If player presses confirm or continue button
			if typing:  # If text is still typing 
				textbox_text.visible_characters = textbox_text.text.length()  # Instantly show full text
				typing = false  # Stop typewriter effect
				GlobalSignals.stop_sound.emit("typing_sound")  # Stops typing sound
				Herr_Dahm.set_deferred("animation", "default")  # Stops mouth animation
			else:
				next_script()  # If text already fully visible, move to next dialogue line
	else:
		# After dialogue ends, trigger duck particle effects
		$DuckParticles.set_deferred("emitting", true)  # Starts normal duck particles
		$DuckParticles_flipped.set_deferred("emitting", true)  # Starts flipped duck particles
		set_process_input(false)  # Disables further input

#Loads the next dialogue line from the dialogue list and prepares the typewriter effect
func next_script():
	current_dialogue_id += 1

	# End of dialogue
	if current_dialogue_id == len(dialogue) - 1:
		#d_active = false
		#textbox.visible = false
		#ends input event and emits ducks during last line read before returning to home screen
		dialogue_done = true

	# Sets name and text from JSON
	textbox_name.text = dialogue[current_dialogue_id]['name']
	textbox_text.text = dialogue[current_dialogue_id]['text']

	# Prepares typewriter effect
	char_index = 0
	textbox_text.visible_characters = 0
	typing = true
	timer.start()


# Typing effect: reveals characters one by one each frame
func _on_timer_timeout() -> void:
	if not typing: # if it´s not typing then stop the timer
		timer.stop()
		return

	char_index += 1 #else add a character every 0.05 seconds
	textbox_text.visible_characters = char_index # update 

	if char_index <= textbox_text.text.length():
		Herr_Dahm.set_deferred("animation", "open") #Plays Animation aslong as text is typed
		# if there are still characters left play sound 
		GlobalSignals.play_sound.emit("typing_sound")
		#stop sound and typing when ther are no characters left
	if char_index >= textbox_text.text.length():
		typing = false
		timer.stop()
		GlobalSignals.stop_sound.emit("typing_sound") 
		Herr_Dahm.set_deferred("animation", "default") #Stops Mouth movement

# is called when the flipped duck particle animation ends
func _on_duck_particles_flipped_finished() -> void:
	$fade_in/AnimationPlayer.play("RESET")
