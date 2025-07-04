extends StaticBody2D
#Placed on the Map as an Object
#Collision handled as this Object is marked as a wall, but also as Hitable by Player
#Spawns Item (sometimes) on death via Global Signal

## VARIABLES
var hitpoints = 3 #hits required to destroy and spawn item

## FUNCTIONS
func _ready():
	pass

#First two hits play an Animation, last hit explodes into particles and spawns Item
func take_damage():
	hitpoints -= 1
	
	match (hitpoints):
		1,2: 
			$Sprite2D/AnimationPlayer.stop() #To be able to play Animation on every hit
			$Sprite2D/AnimationPlayer.play("hit")
			$HitParticle_1.set_deferred("emitting", true)
		0:
			$Sprite2D/AnimationPlayer.stop()
			$Sprite2D/AnimationPlayer.play("destroyed")
			$CollisionShape2D.set_deferred("disabled", true) 
			$HitSound.play()
			GlobalSignals.drop_item.emit(global_position)

#Remove Instance after Particles triggered by "destroyed" Animation is finnished
func _on_hit_particle_3_finished() -> void:
	queue_free()
