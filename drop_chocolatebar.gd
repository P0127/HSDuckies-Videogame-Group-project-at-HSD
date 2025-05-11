extends Area2D


func _ready():
	pass 

func _on_body_entered(body):
	
		print("Chocolatebar is collected!")
		queue_free()  # Entfernt den Energy Drink aus der Szene
		
