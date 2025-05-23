extends Area2D


func _ready():
	pass 

func _on_body_entered(body):
	print("Chocolatebar is collected!")
	
	queue_free()  # Entfernt den Energy Drink aus der Szene
	GlobalSignals.boost_firerate_collected_signal.emit()#using a global script to get the signal
	#to the hud without requiring it to be a child/parent node 

func pickup(body : Node2D):
	print("effect")
	
