extends CharacterBody2D

#maybe potential future link to player for scaling?
var movement_speed = 45 #+ 10 * PlayerLevel 
@onready var main = $"/root/Main"
@onready var player = $"/root/Main/Player"
var target #saveslot for current target to make it possible to run out of aggro range
@export var health = 3 #Hits required to kill

#to Instantiate drop item later on
var drop_scene := preload("res://duck_collectable.tscn")

func _ready():
	#We only have to change one Variable, Progress Bar adjusts automaticly
	$ProgressBar.max_value = health
	$ProgressBar.value = health
	$ProgressBar.hide()

func _physics_process(delta):
	velocity = Vector2.ZERO
	if target:
		velocity = global_position.direction_to(target.global_position) * movement_speed
		move_and_slide()
		
	#Inactive Animation standing still
	if velocity.length() == 0:
		$AnimatedEnemySprite.animation = "inactive"
	#Flips Animation if walking to the side
	if velocity.x != 0:
		$AnimatedEnemySprite.animation = "active"
		# uprightposture
		$AnimatedEnemySprite.flip_v = false
		$AnimatedEnemySprite.flip_h = velocity.x < 0

#the two following functions go into effect whenever any body enters our mobs AwarenessRadius
#if the body is a player we set it as current target/if player body leaves AwarenessRadius we 
#get rid of the target on the player
#this can be used as aggro range/maybe for a future stealth mechanic 
func _on_DetectRadius_body_entered(body):
	if body==player:
		target = player
	#pass 

func _on_DetectRadius_body_exited(body):
	if body==player:
		target = null
	#pass

#for use of NavigationAgent2D stuff we'll first need to define the map with connected nodes aka with
#other 2D Nav nodes


#temporarily added for mobs to despawn upon leaving players screen... will prob remove later or
#try to find a way to increase range in order to avoid player just despawning everything with
#edge of screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

#Subtracts Hitpoints from Mob
func take_damage():
	health -= 1
	$ProgressBar.show()
	$ProgressBar.value = health
	if health == 0:
		die()

#When Mob gets killed, Animations get stopped
func die():
	#Makes the Mob Stop responding or Animating
	#Unneeded if we just use queue_free in the end
	$AnimatedEnemySprite.stop()
	$Hitbox.set_deferred("disabled",true)
	$AwarenessRadius/CollisionShape2D.set_deferred("disabled",true)
	#can be taken out in case we want a death animation first... etc
	queue_free()
	drop_item()

#Calls on the preloaded duck drop scene to instantiate it once
func drop_item():
	var drop = drop_scene.instantiate()
	drop.position = position
	#will run after physics proccessees, lessens errors (deferred)
	main.call_deferred("add_child", drop)
