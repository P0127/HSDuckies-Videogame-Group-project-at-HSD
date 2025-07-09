extends CanvasLayer

## FUNCTIONS MENU BUTTON
func _on_menu_pressed() -> void:
	GlobalSignals.play_sound.emit("starting_sound")
	$ControlMenu/Menu/AnimatedMenuButton.play("pressed")
	
	

func _on_animated_menu_button_animation_finished() -> void:
	#signals the scene controller to switch to start screen and to remove the current scene(game over)
	GlobalSignals.scene_controller.remove_scene()
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")


## FUNCTIONS QUIT BUTTON
func _on_quit_pressed() -> void:
	GlobalSignals.play_sound.emit("starting_sound")
	#starts the pressed animation for quit button
	$ControlQuit/Quit/AnimatedQuitButton.play("pressed")
	
	

func _on_animated_quit_button_animation_finished() -> void:
	#once the pressed animation is finished the game is exited
	get_tree().quit()
