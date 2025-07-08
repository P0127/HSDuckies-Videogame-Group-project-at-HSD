extends Node
# is called automatically when the scene is ready
func _ready():
	#To connect global play and stop signals to local functions
	GlobalSignals.play_sound.connect(_play_sound)
	GlobalSignals.stop_sound.connect(_stop_sound)
	
#is called when the "play_sound" signal is emitted.
func _play_sound(name: String):
	# Makes sure it's an AudioStreamPlayer and it's not already playing
	if has_node(name):
		var player = get_node(name)
		#Only starts sound if none is playing
		if player is AudioStreamPlayer and not player.playing:
			player.play() # plays sound
		
#is called when the "stop_sound" signal is emitted.
func _stop_sound(name: String):
	# 'name' is the name of the AudioStreamPlayer node to stop.
	if has_node(name):
		# Checks if the node exists
		var player = get_node(name)
		# Ensures it's an AudioStreamPlayer and stop it
		if player is AudioStreamPlayer:
			player.stop() #stops sound
			
