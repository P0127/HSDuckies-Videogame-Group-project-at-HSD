extends StaticBody2D

var hitpoints = 3 #hits required to destroy and spawn item


func _ready():
	pass

func take_damage():
	hitpoints -= 1
	
	match (hitpoints):
		2: 
			$Sprite2D/AnimationPlayer.stop()
			$Sprite2D/AnimationPlayer.play("hit")
			$HitParticle_1.set_deferred("emitting", true)
			$HitSound.play()
		1:
			$Sprite2D/AnimationPlayer.stop()
			$Sprite2D/AnimationPlayer.play("hit")
			$HitParticle_2.set_deferred("emitting", true)
			$HitSound.play()
		0:
			$Sprite2D/AnimationPlayer.stop()
			$Sprite2D/AnimationPlayer.play("destroyed")
			$CollisionShape2D.set_deferred("disabled", true)
			$HitSound.play()
			GlobalSignals.drop_item.emit(global_position)



func destroy():
	queue_free()
