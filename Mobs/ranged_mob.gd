extends CharacterBody2D

## SCENES (multiple usage)
@onready var main = $"/root/Main"
@onready var progressBar = $ProgressBar
@onready var spriteMob = $AnimatedRangedMobSprite
@onready var weapon = $mob_weapon
@onready var spriteDuckmask = $DuckmaskSprite

var drop_scene := preload("res://Drops/duck_collectable.tscn") #to Instantiate drop item later on
var run_away_scene := preload("res://Mobs/mob_run_away.tscn") #to instantiate scene of mob running away upon defeat

## STATS
var health = 3 #Hits required to kill
var movement_speed = 100 #+ 10 * PlayerLevel 
var damage_rate : float = 3.0 #damage done to Player by touching

## TARGETS
var target_damage : Node2D #saveslot for Player on body entered
var target_homing : Node2D #saveslot for current target to make it possible to run out of aggro range
var weapon_direction = Vector2.RIGHT #used for weapon direction
var duck_status : int = 1 #modifier for running direction, dependant on wether it's a duck (1) or student (-1)

func _ready():
	#We only have to change one Variable, Progress Bar adjusts automaticly
	progressBar.max_value = health
	progressBar.value = health
	progressBar.hide()

func _process(delta: float):
	progressBar.value = health

func _physics_process(delta : float):
	
	## MOVEMENT
	velocity = Vector2.ZERO
	#target_homing is the Player Node (checked in Signals) and calls on Player Position
	if target_homing:
		velocity = global_position.direction_to(target_homing.global_position) * movement_speed * duck_status
		move_and_slide()
		
	## SPRITE ORIENTATION
	_rotate_sprite()
	_rotate_weapon()
	
	## COLLISION
	#target_damage is the Player Node (checked in Signals) and calls the Player Function damage
	if target_damage:
		target_damage.take_damage(delta, damage_rate)



#function that manages the sprite animation
func _rotate_sprite():
	if velocity != Vector2.ZERO:
		#int to eliminate decimals (reduces errors)
		#rad to deg to have easy, whole numbers to work with
		#velocity.angle() gives back angle (right is 1,0 - down is 0,1) in radians!
		match int(rad_to_deg((velocity.angle()))):
			-90:
				spriteMob.animation = "back"
				spriteDuckmask.animation = "back"
			45, 90, 135: 
				spriteMob.animation = "front"
				spriteDuckmask.animation = "front"
			0, -45, 180, -135:
				spriteMob.animation = "side"
				spriteDuckmask.animation = "side"
		#Flips Animation if walking to the side
		spriteMob.flip_h = velocity.x < 0 * duck_status
		spriteDuckmask.flip_h = velocity.x < 0 * duck_status
	else:
		spriteMob.animation = "front"
		spriteDuckmask.animation = "front"

#function that manages the weapon rotation
func _rotate_weapon():
	weapon_direction = velocity.normalized()
	weapon.rotation = weapon_direction.angle()
	
	if target_homing:
		weapon.attack(true)
		spriteDuckmask.speed_scale = 0.2
		spriteDuckmask.play()
	else:
		weapon.attack(false)
		spriteDuckmask.pause()


#Subtracts Hitpoints from Mob
func take_damage():
	if health > 0:
		health -= 1
		progressBar.show()
		$OuchParticles.set_deferred("emitting", true)
	if health == 0:
		#_die()
		health = -1
		progressBar.hide()
		liberated()

#When Mob gets killed, Animations get stopped
#func die():
	##Makes the Mob Stop responding or Animating
	##Unneeded if we just use queue_free in the end
	#$CollisionShape.set_deferred("disabled",true)
	#$AwarenessRadius/AwarenessBox.set_deferred("disabled",true)
	#$HurtPlayerArea/HurtBox.set_deferred("disabled", true)
	##can be taken out in case we want a death animation first... etc
	#run_away()#spawns running away scene BEFORE we get rid of current mob
	#queue_free()
	#drop_item()

#Calls on the preloaded duck drop scene to instantiate it once
func drop_item():
	var drop = drop_scene.instantiate()
	drop.position = position
	#will run after physics proccessees, lessens errors (deferred)
	main.call_deferred("add_child", drop)

#function to spawn the running away scene
#func run_away():
	#var running = run_away_scene.instantiate()
	#running.position = position
	#main.call_deferred("add_child", running)

func liberated():
	duck_status = -1 #becomes a student, runs away from Player
	movement_speed = 300
	
	#No Hitbox, no Awareness/targeting, Duckmask falls off
	$HurtPlayerArea/HurtBox.set_deferred("disabled", true)
	$AwarenessRadius/AwarenessBox.apply_scale(Vector2(2.0, 2.0))
	spriteDuckmask.set_deferred("visible", false)
	$FeatherExplosion.set_deferred("emitting", "true")
	$FeatherExplosion2.set_deferred("emitting", "true")
	weapon.set_deferred("disabled", true)
	weapon.hide()
	progressBar.hide()
	drop_item()


#temporarily added for mobs to despawn upon leaving players screen... will prob remove later or
#try to find a way to increase range in order to avoid player just despawning everything with
#edge of screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#await $FeatherExplosion.finished
	queue_free()

#the two following functions go into effect whenever any body enters our mobs AwarenessRadius
#if the body is a player we set it as current target/if player body leaves AwarenessRadius we 
#get rid of the target on the player
func _on_DetectRadius_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		target_homing = body

func _on_DetectRadius_body_exited(body : Node2D):
	if body.is_in_group("Player"):
		target_homing = null

#the two following functions go into effect whenever any body enters our mobs HitBox
#if the body is a player we set it as current target/if player body leaves HitBox we 
#get rid of the target on the player
func _on_hurt_player_area_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		target_damage = body
		spriteDuckmask.speed_scale = 1
		spriteDuckmask.play()

func _on_hurt_player_area_body_exited(body : Node2D):
	if body.is_in_group("Player"):
		target_damage = null
		spriteDuckmask.pause()
