extends CanvasLayer


func _on_menu_pressed() -> void:
	$Menu/AnimatedMenuButton.play("pressed")
	
	await get_tree().create_timer(0.5).timeout
	

	get_tree().change_scene_to_file("res://main.tscn")
	
	


func _on_quit_pressed() -> void:
	$Quit/AnimatedQuitButton.play("pressed")
	
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
