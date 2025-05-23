extends Area2D

@export var health_healed = 40

func _ready():
	pass 

func _on_body_entered(body):
	print("Canteen food is collected!")
	
	queue_free()  # Entfernt den Energy Drink aus der Szene
	GlobalSignals.health_collected_signal.emit() #using a global script to get the signal
	#to the hud without requiring it to be a child/parent node 
