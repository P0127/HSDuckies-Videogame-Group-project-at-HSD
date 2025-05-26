extends Area2D


func _ready():
	pass

func pickup(player : Node2D):
	print("ENERGY DRINK METHOD")
	player.speed_up(100, true)
	GlobalSignals.timer_speedUp.start(3)
	queue_free()

func _timer_timeout():
	pass

func _on_global_timer_speedUp_timeout():
	print("timer")
