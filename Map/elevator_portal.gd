extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		manage_PlayerCamera_panning(body, false)
		body.set_position($destinationPoint.global_position)
		await get_tree().create_timer(0.05).timeout
		manage_PlayerCamera_panning(body, true)
		
		##Going to the 2nd floor will toggle mobs dropping ducks and natural spawns
		GlobalSignals.toggle_mob_drops.emit()
		GlobalSignals.toggle_natural_spawns.emit()

func manage_PlayerCamera_panning (body : Node2D, panEnabled : bool = false):
	if body.has_node("PlayerCamera"):
		body.get_node("PlayerCamera").position_smoothing_enabled = panEnabled
