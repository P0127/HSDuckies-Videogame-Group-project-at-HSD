extends CharacterBody2D

## SCENES (multiple usage)
@onready var progressBar = $ProgressBar
@onready var spriteMob = $AnimatedRangedMobSprite
@onready var weapon = $mob_weapon
@onready var spriteDuckmask = $DuckmaskSprite
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D


var drop_scene := preload("res://Drops/duck_collectable.tscn") #to Instantiate drop item later on
var run_away_scene := preload("res://Mobs/mob_run_away.tscn") #to instantiate scene of mob running away upon defeat

## STATS
static var moblvl = 1
var health : int = 2 + moblvl/2  #Hits required to kill
var movement_speed = 100 + (moblvl-1) * 25
var damage_rate : float = 3.0  #damage done to Player by touching


## TARGETS
var target_damage : Node2D #saveslot for Player on body entered
var target_homing : Node2D #saveslot for current target to make it possible to run out of aggro range
var weapon_direction = Vector2.RIGHT #used for weapon direction
var duck_status : int = 1 #modifier for running direction, dependant on wether it's a duck (1) or student (-1)



func _ready():
	if not GlobalSignals.duck_collected_levelUp.is_connected(_levelUp):
		GlobalSignals.duck_collected_levelUp.connect(_levelUp)
	
	#added firerate scaling
	var firerate_adjustment = (moblvl-1) * 0.2 #this depends on how high we want it to scale
	weapon.change_firerate(3-firerate_adjustment, true)
	
	#We only have to change one Variable, Progress Bar adjusts automaticly
	progressBar.max_value = health
	progressBar.value = health
	progressBar.hide()

@warning_ignore("unused_parameter")
func _process(delta: float):
	progressBar.value = health

func _physics_process(delta : float):
	
	## MOVEMENT
	velocity = Vector2.ZERO
	#target_homing is the Player Node (checked in Signals) and calls on Player Position
	if target_homing:
		var target_location = target_homing.global_position
		navigation_agent_2d.target_position = target_location
		
		var current_agent_position = self.global_position
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed * duck_status
		
		#if navigation_agent_2d.is_navigation_finished():
		#	return #could add some kinda meelee hit animation 
		
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		
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


#Calls on the preloaded duck drop scene to instantiate it once
func drop_item():
	GlobalSignals.drop_duck.emit(global_position)


func liberated():
	duck_status = -1 #becomes a student, runs away from Player
	movement_speed = 300
	$Time_to_live.start()
	
	#No Hitbox, no Awareness/targeting, Duckmask falls off
	$HurtPlayerArea/HurtBox.set_deferred("disabled", true)
	$AwarenessRadius/AwarenessBox.apply_scale(Vector2(2.0, 2.0))
	spriteDuckmask.set_deferred("visible", false)
	$FeatherExplosion.set_deferred("emitting", "true")
	$FeatherExplosion2.set_deferred("emitting", "true")
	$SweatParticles.set_deferred("emitting", "true")
	weapon.set_deferred("disabled", true)
	weapon.hide()
	weapon.swap_fire_status()
	progressBar.hide()
	drop_item()

func _on_time_to_live_timeout() -> void:
	GlobalSignals.reduce_mob_counter.emit()
	var tween = get_tree().create_tween()
	# Tween the modulate.a property to 0 (not visible)
	tween.tween_property(self, "modulate:a", 0, 0.6)
	# When the fade-in is complete, queue_free entire Instance
	tween.tween_callback(self.queue_free)

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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

static func _levelUp():
	moblvl += 1
	#prints("Ranged have levelled up to lvl: ", moblvl)
