extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		manage_PlayerCamera_panning(body, false)
		body.set_position($destinationPoint.global_position)
		await get_tree().create_timer(0.05).timeout
		manage_PlayerCamera_panning(body, true)

func manage_PlayerCamera_panning (body : Node2D, panEnabled : bool = false):
	if body.has_node("PlayerCamera"):
		print("Camera", panEnabled)
		body.get_node("PlayerCamera").position_smoothing_enabled = panEnabled
