extends Node2D

@export var d_file: String  # Path to JSON dialogue file


# Node references
@onready var textbox = $textbox
@onready var textbox_name = $textbox/name
@onready var textbox_text = $textbox/text
@onready var Herr_Dahm = $"Herr Dahm"
@onready var timer = $Timer
var dialogue = []   # Loaded dialogue lines
var current_dialogue_id = -1   # Current dialogue index
var d_active = false  
var dialogue_done := false # Deactivates input event upon dialogue end

# Typewriter effect variables
var typing = false
var char_index = 0


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
	if event.is_action_pressed("skip_cutscene"):
		$fade_in/AnimationPlayer.play("RESET")
		dialogue_done = true
		set_process_input(false)
		GlobalSignals.stop_sound.emit("typing_sound")
		return
	if not dialogue_done:
		if event.is_action_pressed("ui_accept"):
			if typing:
				# If typing, immediately show full text and stop sound
				textbox_text.visible_characters = textbox_text.text.length()
				typing = false
				GlobalSignals.stop_sound.emit("typing_sound") 
			else:
				# Move to next dialogue line
				next_script()
	else:
		#Triggers Duck spawning
		$DuckParticles.set_deferred("emitting", true)
		$DuckParticles_flipped.set_deferred("emitting", true)
		set_process_input(false)


func next_script():
	current_dialogue_id += 1

	# End of dialogue
	if current_dialogue_id == len(dialogue) - 1:
		#d_active = false
		#textbox.visible = false
		#ends input event and emits ducks during last line read before returning to home screen
		dialogue_done = true

	# Set name and text from JSON
	textbox_name.text = dialogue[current_dialogue_id]['name']
	textbox_text.text = dialogue[current_dialogue_id]['text']

	# Prepare typewriter effect
	char_index = 0
	textbox_text.visible_characters = 0
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
	textbox_text.visible_characters = char_index # update 

	if char_index <= textbox_text.text.length():
		# if there are still characters left play sound 
		
				GlobalSignals.play_sound.emit("typing_sound")
		#stop sound and typing when ther are no characters left
	if char_index >= textbox_text.text.length():
		typing = false
		timer.stop()
		GlobalSignals.stop_sound.emit("typing_sound")
		Herr_Dahm.play("default")


func _on_duck_particles_flipped_finished() -> void:
	$fade_in/AnimationPlayer.play("RESET")
