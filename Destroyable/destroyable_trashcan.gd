extends StaticBody2D

## VARIABLES
var hitpoints = 3 #hits required to destroy and spawn item

#Different Trashcan styles
var paper : Texture2D = preload("res://Destroyable/Destroyable_assets/Trashcan_Paper.png")
var plastic : Texture2D = preload("res://Destroyable/Destroyable_assets/Trashcan_Plastic.png")
var waste : Texture2D = preload("res://Destroyable/Destroyable_assets/Trashcan_Waste.png")
#Different Particle Styles, dependant on Trashcan Style
var paper_effect : Texture2D = preload("res://assets/effects/Trashcan_paper.png")
var plastic_effect : Texture2D = preload("res://assets/effects/Trashcan_plastic.png")
var waste_effect : Texture2D = preload("res://assets/effects/Trashcan_waste.png")

var trash_types = [paper, plastic, waste]
var trash_types_effect = [paper_effect, plastic_effect, waste_effect]


## FUNCTIONS
#On Initiation, randomizes Trashcan Type, sets fitting particles
func _ready():
	randomize()
	var randomIndex : int = randi() % trash_types.size()  #Liefert Zufallszahl zwischen 0 und 2
	if randomIndex <= trash_types.size():
		$Sprite2D.texture = trash_types[randomIndex]
	if randomIndex <= trash_types_effect.size():
		$Trash_Explosion.texture = trash_types_effect[randomIndex]

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
			$HitSoundTrashcan.play()
			GlobalSignals.drop_item.emit(global_position)

#Remove Instance after Particles triggered by "destroyed" Animation is finnished
func _on_hit_particle_3_finished() -> void:
	queue_free()
