extends Area2D


func _ready():
	pass  

func _on_body_entered(body):
	
		print("Energy Drink is collected!")
		queue_free()  # Entfernt den Energy Drink aus der Szene
		
