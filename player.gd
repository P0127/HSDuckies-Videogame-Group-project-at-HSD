extends CharacterBody2D

signal health_death #Custom Signal; Death / Game_over due to health depletion

@export var speed = 400 #player movement speed in pixels/sec
var screen_size #game window size
var current_direction = Vector2.ZERO #Direction Player is moving in
var movement_timer : float = 0.0 #timer to count how long moving in a direction
var weapon_direction_change_min_time = 0.1 #time how long is needed till weapon direction changes 
var last_direction = Vector2.RIGHT #saveslot for where we were last moving/for when we stop
var last_direction_faced = Vector2.RIGHT #saveslot for the last direction faced while moving
#RIGHT: weapon spawns default on that side


const max_health = 100.0 #Set Health Amount
@export var health = max_health #Player health current

# Called when the node enters the scene tree for the first time.
func _ready():
	#screen_size = get_viewport_rect().size
	#^not needed rn since we move camera with player
	#could be useful later for enemy spawning maybe if reset on every frame limit spawn area to around player?
	hide() #hides player on startup to avoid showing behind hud
	#We only have to change one Variable, Progress Bar adjusts automaticly
	$ProgressBar.max_value = health
	$ProgressBar.value = health
	
	#Listens to the following Signals
	GlobalSignals.health_collected_signal.connect(health_collected)
	GlobalSignals.boost_speed_collected_signal.connect(boost_speed_collected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# The player's movement vector.
	var velocity = Vector2.ZERO 
	#check for collisions
	var collision_info = move_and_collide(velocity * delta)
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#normalized so that player is not faster moving diagonally 
	
	#Player can move
	position += velocity * delta
	
	#count up how long we've been moving
	movement_timer += delta
	
	#Correct Sprite and Weapon Rotation
	rotate_sprite(velocity, movement_timer)
	rotate_weapon(last_direction_faced)
	#If this is done in the function, would only be saved globally
	if movement_timer >= weapon_direction_change_min_time:
		movement_timer = 0#reset timer
	
	#Checking each Frame if Mobs are touching the Player
	var overlapping_mobs = $HurtBox.get_overlapping_bodies()
	const DAMAGE_RATE = 10.0 #Damage the Mobs do to the Player (maybe give this to mobs?)
	
	if overlapping_mobs.size() > 0:
		#Why Delta? Else we'd loose health per Frame, not per Second!
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta 
		#Progress Bar is linked with health Variable
		if health <= 0.0:
			health_death.emit()
			print("DEATH")
			
	#Updates progress bar
	$ProgressBar.value = health


#function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	#starts the animation
	$AnimatedPlayerSprite.play()
	$PlayerCollisionShape.disabled = false


#function that rotates the weapon along with the players movement
#atan2 math is needed to calc the Vector2 into a rotation angle
func rotate_weapon(direction_player):#direction param is a Vector2 here
	#both work via vector
	$"player weapon".rotation = direction_player.angle()
	#Corrects Position of Weapon due to Sprite model
	match int(rad_to_deg((direction_player.angle()))):
		-90:
			$"player weapon".position.y = -60
			$"player weapon".position.x = 0
		-45:
			$"player weapon".position.x = 80
		-135:
			$"player weapon".position.x = -80
		_:
			$"player weapon".position.y = 150
			$"player weapon".position.x = 0

func rotate_sprite(velocity, movement_timer):
	#Which Animation plays
	if velocity != Vector2.ZERO:
		#int to eliminate decimals (reduces errors)
		#rad to deg to have easy, whole numbers to work with
		#velocity.angle() gives back angle (right is 1,0 - down is 0,1) in radians!
		match int(rad_to_deg((velocity.angle()))):
			-90:
				$AnimatedPlayerSprite.animation = "walk_back"
			45, 90, 135: 
				$AnimatedPlayerSprite.animation = "walk_front"
			0, -45, 180, -135:
				$AnimatedPlayerSprite.animation = "walk_side"
		#Flips Animation if walking to the side
		$AnimatedPlayerSprite.flip_h = velocity.x < 0
		
		#saveslot for last direction faced while walking, without reseting in "stand" mode
		#only saves this value, if direction has been faced for a fixed while
		if movement_timer >= weapon_direction_change_min_time:
			last_direction_faced = velocity
	else:
		$AnimatedPlayerSprite.animation = "stand"
	


# Functions for the Signals received
func health_collected():
	if (health + 20.0) < max_health:
		health += 20.0
		
	else:
		health = max_health

func boost_speed_collected():
	$PickUp/EffectTimer.start(3)
	speed = 500 #we may want to increase this a bit to make it more noticeable

func _on_effect_timer_timeout() -> void:
	speed = 400

#Subtracts Hitpoints from Player #honestly no clue why we didnt have this here yet
func take_damage():
	health -= 1
	$ProgressBar.show()
	$ProgressBar.value = health
	if health == 0:
		print("you died")
