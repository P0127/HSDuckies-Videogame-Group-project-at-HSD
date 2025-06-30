class_name Player extends CharacterBody2D

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

## FLAGS
#Check to only play Dialogue once
var dialogue_start_triggered : bool = true #gets set on initialisation
var dialogue_pickup_triggered : bool = false #gets set on item_pickup

## FUNCTIONS PRESET
#Called when the node enters the scene tree for the first time.
func _ready():
	#We only have to change one Variable, Progress Bar adjusts automaticly
	progressBar.max_value = max_health
	progressBar.value = health
	
	#adds this to the Player group to be called on globally for body (entered) checks
	add_to_group("Player")
	
	#Global Timer timeouts to reset stats
	GlobalSignals.timerSpeedUp.connect("timeout", _on_global_speedUp_timeout)
	#To Level Up (triggered by HUD counter)
	GlobalSignals.duck_collected_levelUp.connect(_levelUp)
	#Starts Game-won Animation
	GlobalSignals.game_won.connect(_on_game_won)

#Function for start of game to move player to start position and show player
#Called by Level on game start after intro
func start(pos):
	position = pos
	#starts the animation
	spritePlayer.play()
	$PlayerCollisionShape.disabled = false
	dialogue_start_triggered = false

@warning_ignore("unused_parameter")
#Called as often as possible. For effects and independent proccesses
func _process(delta : float):
	progressBar.max_value = max_health #Updates progress bar relative size
	progressBar.value = health #Updates bar progress
	if !dialogue_start_triggered:
		# Start the dialogue with the specified JSON dialogue file, pauses game
		GlobalSignals.dialogue_start.emit("res://Dialogue_cutscenes/dialog_anfang.json")
		dialogue_start_triggered = true
		$PlayerCamera.position_smoothing_enabled = true #After Dialogue Camera is smooth

#Called every frame. 'delta' is the elapsed time since the previous frame. Keeps Framerate
func _physics_process(delta : float):
	
	## MOVEMENT
	velocity = Vector2.ZERO #Player's movement vector reset for every Frame
	_movement(delta) #Player's movement via Keyboard Input
	movement_timer += delta #count up how long we've been moving, relevant for Weapon rotation
	
	## SPRITE ORIENTATION
	_rotate_sprite(movement_timer)
	_rotate_weapon()
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
	if(!godmode): #for debugging
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

#function that rotates the weapon to aim at the current mouse position
func _rotate_weapon(): 
	var direction_vector = get_global_mouse_position() - self.global_position
	direction_vector = direction_vector.normalized() #No faster movement on diagonal
	var angle = direction_vector.angle()
	weapon.rotation = angle
	
	#Layers Weapon correctly relative to Player Sprite
	if int(rad_to_deg(angle)) < 0:
		weapon.show_behind_parent = true
	else:
		weapon.show_behind_parent = false


## FUNCTIONS STATS
#Called on LevelUp (Level_Manager, enough ducks collected)
func _levelUp ():
	level += 1
	max_health += HEALTH_ON_LEVELUP #Adds Health per level
	heal(HEALTH_ON_LEVELUP * 1.5) # heals you a bit more than the max health you gain
	
	$LevelUp.set_deferred("emitting", true) #LevelUp Animation

#Heals Player by Amount, doesn't exceed max_health
func heal(heal_amount : float):
	if (health + heal_amount) < max_health:
		health += heal_amount
	else:
		health = max_health

#Adds onto speed non collectively (chooses the highest boost)
func speed_up(speed_amount : int):
	if speed < STANDARD_SPEED + speed_amount:
		speed = STANDARD_SPEED + speed_amount

#Resets speed once global timer on speedUp runs out (SpeedUp Time adds up)
func  _on_global_speedUp_timeout():
	speed = STANDARD_SPEED

#Changes firerate, parameter increases the rate of it being shot
func increase_firerate(firerate_amount : float):
	$"player weapon".boost_firerate_collected(firerate_amount)

#Disables Player, starts death animation
func _die():
	_disable_player_interactions()	
	$SoundDie.play()
	$AnimatedPlayerSprite/AnimationPlayer.play("scale")

#Disables Player, starts victory animation
func _on_game_won():
	_disable_player_interactions()
	$SoundWin.play()
	$AnimatedPlayerSprite/AnimationPlayer.play("game_won")

#Stops Interactions, Freezes Player
func _disable_player_interactions():
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$PickUp/CollisionShape2D.set_deferred("disabled", true)
	$PlayerCollisionShape.set_deferred("disabled", true)
	$OuchParticles.set_deferred("visible", false)
	#no movement allowed
	speed = 0

## FUNCTIONS SIGNALS
@warning_ignore("unused_parameter")
#Handles Game State Signals on animation finished
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "scale":
		#global game over
		GlobalSignals.game_over.emit()
	elif anim_name == "game_won":
		#emits Signal to start end_dialogue
		GlobalSignals.duck_counter._game_won()

#checks if touched body is an allowed pickup (has a method called pickup to be called)
func _on_pick_up_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickupable_player"):
		#Triggers on first pickup
		if !dialogue_pickup_triggered:
			dialogue_pickup_triggered = true
			# Set the dialogue file and start the dialogue
			GlobalSignals.dialogue_start.emit("res://Dialogue_cutscenes/ZwischenDialog_1.json")
		else:
			print("DEBUG: PickUp Dialogue not triggered")
		area.pickup(self) #Calls on Pickup Method

#big range around player used for despawning mobs if too far away
#to keep mob counter in control
func _on_despawnrange_body_exited(body: Node2D) -> void:
	if body.is_in_group("all_mobs"):
		body.queue_free()
		GlobalSignals.reduce_mob_counter.emit()
