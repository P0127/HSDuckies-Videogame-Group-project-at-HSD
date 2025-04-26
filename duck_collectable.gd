extends Area2D



func _ready():
	pass
	

func _on_body_entered(body):
	print("Collected")
	queue_free()
	GlobalSignals.duck_collected_signal.emit()#using a global script to get the signal
	#to the hud without requiring it to be a child/parent node 
