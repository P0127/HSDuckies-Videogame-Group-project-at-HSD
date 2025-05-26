extends Area2D

func _ready():
	# Starts Animation once
	$DuckPath/DuckPathFollow/AnimatedSprite2D.play("flapping")
	


func _physics_process(delta):
	if ($DuckPath/DuckPathFollow.progress_ratio != 1):
		$DuckPath/DuckPathFollow.progress_ratio += 0.015
	else:
		# Ends Animation once path has finnished
		$DuckPath/DuckPathFollow/AnimatedSprite2D.animation = "default"


func _on_body_entered(body):
	queue_free()
	GlobalSignals.duck_collected_signal.emit()#using a global script to get the signal
	#to the hud without requiring it to be a child/parent node 
