extends CharacterBody2D

## SIGNALS
signal health_death #Custom Signal; Death / Game_over due to health depletion

## SCENES (multiple usage)
@onready var progressBar = $ProgressBar
@onready var weapon = $"player weapon"
@onready var spritePlayer = $AnimatedPlayerSprite

## STATS
const MAX_HEALTH : float = 100.0 #Set Health Amount
const STANDARD_SPEED = 250 #original Speed (backup for speedchanges via pickups)
var health = MAX_HEALTH #Player health current
var speed = STANDARD_SPEED #player movement speed in pixels/sec

## ORIENTATION
var current_direction = Vector2.ZERO #Direction Player is moving in
var last_direction = Vector2.RIGHT #saveslot for where we were last moving/for when we stop
var last_direction_faced = Vector2.RIGHT #saveslot for the last direction faced while moving
#RIGHT: weapon spawns default on that side
var movement_timer : float = 0.0 #timer to count how long moving in a direction
var weapon_direction_change_min_time : float = 0.1 #time how long is needed till weapon direction changes 


#Called when the node enters the scene tree for the first time.
func _ready():
	#screen_size = get_viewport_rect().size
	#^not needed rn since we move camera with player
	#could be useful later for enemy spawning maybe if reset on every frame limit spawn area to around player?
	hide() #hides player on startup to avoid showing behind hud
	#We only have to change one Variable, Progress Bar adjusts automaticly
	progressBar.max_value = health
	progressBar.value = health
	
	#Listens to the following Signals
	GlobalSignals.health_collected_signal.connect(health_collected)
	GlobalSignals.boost_speed_collected_signal.connect(boost_speed_collected)


# Function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	#starts the animation
	spritePlayer.play()
	$PlayerCollisionShape.disabled = false


#Called as often as possible. For effects and independent proccesses
func _process(delta):
	
	progressBar.value = health #Updates progress bar


#Called every frame. 'delta' is the elapsed time since the previous frame. Keeps Framerate
func _physics_process(delta):
	
	## MOVEMENT
	velocity = Vector2.ZERO #Player's movement vector reset for every Frame
	_movement(delta) #Player's movement via Keyboard Input
	movement_timer += delta #count up how long we've been moving, relevant for Weapon turn
	
	## SPRITE AND WEAPON ORIENTATION
	_rotate_sprite(movement_timer)
	_rotate_weapon(last_direction_faced)
	#If this is done in the function, would only be saved globally
	if movement_timer >= weapon_direction_change_min_time:
		movement_timer = 0 #reset timer
	
	_collision(delta)


# Function that processes Player's movement
func _movement(delta):
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
func damage(delta, damageAmount : float):
	if health > 0.0:
		#Why Delta? Else we'd loose health per Frame, not per Second!
		health -= damageAmount * delta
	else:
		health_death.emit()
		print("DEATH")


#function that checks all collision
func _collision(delta):
	move_and_collide(velocity * delta) #check for collisions with walls
	_collision_mobs(delta) #checks for collisions with mobs

#function that checks collision with mobs
func _collision_mobs(delta):
	#checking each Frame if Mobs are touching the Player
	var overlapping_mobs = $HurtBox.get_overlapping_bodies()
	const DAMAGE_RATE = 10.0 #damage the Mobs do to the Player (maybe give this to mobs?)
	
	if overlapping_mobs.size() > 0:
		for amount in overlapping_mobs.size():
			damage(delta, DAMAGE_RATE)


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


# Functions for the Signals received
func health_collected():
	if (health + 20.0) < MAX_HEALTH:
		health += 20.0
	else:
		health = MAX_HEALTH

func boost_speed_collected():
	$PickUp/EffectTimer.start(3)
	speed = 500

func _on_effect_timer_timeout() -> void:
	speed = STANDARD_SPEED
