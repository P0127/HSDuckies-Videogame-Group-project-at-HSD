extends CanvasLayer

## FUNCTIONS MENU BUTTON
func _on_menu_pressed() -> void:
	$ControlMenu/Menu/AnimatedMenuButton.play("pressed")

func _on_animated_menu_button_animation_finished() -> void:
	GlobalSignals.scene_controller.remove_scene()
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")


## FUNCTIONS QUIT BUTTON
func _on_quit_pressed() -> void:
	$ControlQuit/Quit/AnimatedQuitButton.play("pressed")

func _on_animated_quit_button_animation_finished() -> void:
	get_tree().quit()
