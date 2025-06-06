extends CanvasLayer

signal game_over

func _on_menu_pressed() -> void:
	$Menu/AnimatedMenuButton.play("pressed")
	
	await get_tree().create_timer(0.5).timeout
	
	game_over.emit()
	get_tree().change_scene_to_file("res://main.tscn")
	
	


func _on_quit_pressed() -> void:
	$Quit/AnimatedQuitButton.play("pressed")
	
	await get_tree().create_timer(0.5).timeout
	game_over.emit()
	get_tree().quit()
