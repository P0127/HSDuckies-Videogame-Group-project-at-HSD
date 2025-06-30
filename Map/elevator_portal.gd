extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#position in world space
		body.set_position($destinationPoint.global_position)
