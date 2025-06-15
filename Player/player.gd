extends CharacterBody2D

## SCENES (multiple usage)
@onready var progressBar = $ProgressBar
@onready var weapon = $"player weapon"
@onready var spritePlayer = $AnimatedPlayerSprite

## STATS
var max_health : float = 10.0  #Set Health Amount, not const as it scales with player level
const STANDARD_SPEED = 250 #original Speed (backup for speedchanges via pickups)
var health = max_health #Player health current
var speed = STANDARD_SPEED #player movement speed in pixels/sec
var level := 1
const HEALTH_ON_LEVELUP = 10
@export var godmode = false #for testing mob stuff

## ORIENTATION
var current_direction = Vector2.ZERO #Direction Player is moving in
var last_direction = Vector2.RIGHT #saveslot for where we were last moving/for when we stop
var last_direction_faced = Vector2.RIGHT #saveslot for the last direction faced while moving
#RIGHT: weapon spawns default on that side
var movement_timer : float = 0.0 #timer to count how long moving in a direction
var weapon_direction_change_min_time : float = 0.1 #time how long is needed till weapon direction changes 


## FUNCTIONS PRESET
#Called when the node enters the scene tree for the first time.
func _ready():
	#screen_size = get_viewport_rect().size
	#^not needed rn since we move camera with player
	#could be useful later for enemy spawning maybe if reset on every frame limit spawn area to around player?
	hide() #hides player on startup to avoid showing behind hud
	#We only have to change one Variable, Progress Bar adjusts automaticly
	progressBar.max_value = health
	progressBar.value = health
	
	#adds this to the Player group to be called on globally for body (entered) checks
	add_to_group("Player")
	
	#Global Timer timeouts to reset stats
	GlobalSignals.timerSpeedUp.connect("timeout", _on_global_speedUp_timeout)
	#To Level Up (triggered by HUD counter)
	GlobalSignals.duck_collected_levelUp.connect(_levelUp)
	GlobalSignals.game_won.connect(_on_game_won)

# Function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	#starts the animation
	spritePlayer.play()
	$PlayerCollisionShape.disabled = false

#Called as often as possible. For effects and independent proccesses
@warning_ignore("unused_parameter")
func _process(delta : float):
	progressBar.value = health #Updates progress bar

#Called every frame. 'delta' is the elapsed time since the previous frame. Keeps Framerate
func _physics_process(delta : float):
	
	## MOVEMENT
	velocity = Vector2.ZERO #Player's movement vector reset for every Frame
	_movement(delta) #Player's movement via Keyboard Input
	movement_timer += delta #count up how long we've been moving, relevant for Weapon turn
	
	## SPRITE ORIENTATION
	_rotate_sprite(movement_timer)
	_rotate_weapon(last_direction_faced)
	#If this is done in the function, would only be saved globally
	if movement_timer >= weapon_direction_change_min_time:
		movement_timer = 0 #reset timer
	
	## COLLISION
	move_and_collide(velocity * delta) #check for collisions with walls


## PHYSICS FUNCTIONS (DELTA)
# Function that processes Player's movement
func _movement(delta : float):
	#checks input and adjusts walking direction accordingly
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	#normalized so that player is not faster moving diagonally 
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	#Player can move
	position += velocity * delta

#function that proccesses damage taken to the Player
func take_damage(delta : float, damage_amount : float):
	if(!godmode): # for testing mob stuff
		if health > 0.0:
			#Why Delta? Else we'd loose health per Frame, not per Second!
			health -= damage_amount * delta
			$OuchParticles.emitting = true
		else:
			_die()


## FUNCTIONS ANIMATIONS
#function that sets Sprite Animation in relation to the direction faced by the Player
func _rotate_sprite(movement_timer : float):
	if velocity != Vector2.ZERO:
		#int to eliminate decimals (reduces errors)
		#rad to deg to have easy, whole numbers to work with
		#velocity.angle() gives back angle (right is 1,0 - down is 0,1) in radians!
		match int(rad_to_deg((velocity.angle()))):
			-90:
				spritePlayer.animation = "walk_back"
			45, 90, 135: 
				spritePlayer.animation = "walk_front"
			0, -45, 180, -135:
				spritePlayer.animation = "walk_side"
		#Flips Animation if walking to the side
		spritePlayer.flip_h = velocity.x < 0
		
		#saveslot for last direction faced while walking, without reseting in "stand" mode
		#only saves this value, if direction has been faced for a fixed while
		if movement_timer >= weapon_direction_change_min_time:
			last_direction_faced = velocity
	else:
		spritePlayer.animation = "stand"

#function that rotates the weapon along with the players movement
func _rotate_weapon(direction_player : Vector2): 
	weapon.rotation = direction_player.angle() #both work via vector
	match int(rad_to_deg((direction_player.angle()))): 
		#Corrects Position of Weapon due to Sprite model
		-90:
			weapon.position.y = -60
			weapon.position.x = 0
		-45:
			weapon.position.x = 80
		-135:
			weapon.position.x = -80
		_:
			weapon.position.y = 150
			weapon.position.x = 0


## FUNCTIONS STATS
func _levelUp ():
	level += 1
	max_health += HEALTH_ON_LEVELUP #Adds Health per level
	heal(HEALTH_ON_LEVELUP * 1.5) # heals you a bit more than the max health you gain
	
	# Might add another weapon later
	
	$LevelUp.set_deferred("emitting", true)

#functions used for pickups 
func heal(heal_amount : float):
	if (health + heal_amount) < max_health:
		health += heal_amount
	else:
		health = max_health

#function adds onto speed non collectively (chooses the highest boost)
func speed_up(speed_amount : int):
	if speed < STANDARD_SPEED + speed_amount:
		speed = STANDARD_SPEED + speed_amount

#resets speed once global timer on speedUp runs out; speed adds on timerwise
func  _on_global_speedUp_timeout():
	speed = STANDARD_SPEED

#changes firerate, parameter increases the rate of it being shot
func increase_firerate(firerate_amount : float):
	$"player weapon".boost_firerate_collected(firerate_amount)


func _die():
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$PickUp/CollisionShape2D.set_deferred("disabled", true)
	$PlayerCollisionShape.set_deferred("disabled", true)
	$OuchParticles.set_deferred("visible", false)
	#no movement allowed
	speed = 0
	
	$AnimatedPlayerSprite/AnimationPlayer.play("scale")

func _on_game_won():
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$PickUp/CollisionShape2D.set_deferred("disabled", true)
	$PlayerCollisionShape.set_deferred("disabled", true)
	$OuchParticles.set_deferred("visible", false)
	#no movement allowed
	speed = 0
	
	$AnimatedPlayerSprite/AnimationPlayer.play("game_won")

## FUNCTIONS SIGNALS
@warning_ignore("unused_parameter")
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "scale":
		GlobalSignals.game_over.emit()
	elif anim_name == "game_won":
		GlobalSignals.duck_counter._game_won()

#checks if touched body has a method called pickup to be called
func _on_pick_up_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickupable_player"):
		area.pickup(self)

#big range around player used for despawning mobs if too far away
#to keep mob counter in control
func _on_despawnrange_body_exited(body: Node2D) -> void:
	if body.is_in_group("all_mobs"):
		body.queue_free()
		GlobalSignals.reduce_mob_counter.emit()

func set_collision_enabled(enabled: bool):
	$PlayerCollisionShape.disabled = not enabled
