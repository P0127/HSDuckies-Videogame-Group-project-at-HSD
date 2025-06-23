extends Node

func _ready():
	#To connect global play and stop signals to local functions
	GlobalSignals.play_sound.connect(_play_sound)
	GlobalSignals.stop_sound.connect(_stop_sound)
	

func _play_sound(name: String, pitch: float = 1.0):
	# Makes sure it's an AudioStreamPlayer and it's not already playing
	if has_node(name):
		var player = get_node(name)
		if player is AudioStreamPlayer and not player.playing:
			player.pitch_scale = pitch # Sets the pitch for duck_collectable 
			player.play() # play sound
		
func _stop_sound(name: String):
	if has_node(name):
		var player = get_node(name)
		if player is AudioStreamPlayer:
			player.stop()
			
