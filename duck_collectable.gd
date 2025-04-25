extends Area2D

func _ready():
	pass
	

func _on_body_entered(body):
	print("Collected")
	queue_free()
