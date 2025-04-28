extends CharacterBody2D

signal health_death #Custom Signal; Death / Game_over due to health depletion

@export var speed = 200 #player movement speed in pixels/sec
var screen_size #game window size
var current_direction#saveslot for weapon/projectile direction
var movement_timer : float = 0.0#timer to count how long moving in a direction
var weapon_direction_change_min_time = 0.5#time how long is needed till weapon direction changes 
var last_direction = Vector2.RIGHT#saveslot for where we were last moving/for when we stop
#by default set to Right to avoid crashes

@export var health = 100.0 #Player health

# Called when the node enters the scene tree for the first time.
func _ready():
	#screen_size = get_viewport_rect().size
	#^not needed rn since we move camera with player
	#could be useful later for enemy spawning maybe if reset on every frame limit spawn area to around player?
	hide() #hides player on startup to avoid showing behind hud
	#We only have to change one Variable, Progress Bar adjusts automaticly
	$ProgressBar.max_value = health
	$ProgressBar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# The player's movement vector.
	var velocity = Vector2.ZERO 
	#check for collisions
	var collision_info = move_and_collide(velocity * delta)
	
	#not needed, as collision is handled by Godot
	#Useful maybe if we want events triggered via collision
	#if collision_info:
		#if Input.is_action_pressed("move_right"):
			#velocity.x += 0
		#if Input.is_action_pressed("move_left"):
			#velocity.x += 0
		#if Input.is_action_pressed("move_down"):
			#velocity.y += 0
		#if Input.is_action_pressed("move_up"):
			#velocity.y += 0
	#else: position += velocity * delta
		
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		current_direction = velocity.normalized() #testing weapon direction
		#rotate_weapon(current_direction)#removed to add delay
		velocity = velocity.normalized() * speed
		#normalized so that player is not faster moving diagonally 
		
		
		last_direction = current_direction#for standing still
		
		#delay added:
		movement_timer += delta#count up how long we've been going in a direction
		if movement_timer >= weapon_direction_change_min_time:
			rotate_weapon(current_direction)#opens method to rotate weapon
			movement_timer = 0#reset timer
	else:#same timer for when we stop moving but had turned
		movement_timer += delta
		if movement_timer >= weapon_direction_change_min_time:
			rotate_weapon(last_direction)
			movement_timer = 0
	
	
	
	
	#Which Animation plays, should be added on to 
	#Flips Animation if walking to the side
	if velocity.x != 0:
		$AnimatedPlayerSprite.animation = "walk"
		# uprightposture
		$AnimatedPlayerSprite.flip_v = false
		$AnimatedPlayerSprite.flip_h = velocity.x < 0
		
	
	#Player can move
	position += velocity * delta
	
	#Checking each Frame if Mobs are touching the Player
	var overlapping_mobs = $HurtBox.get_overlapping_bodies()
	const DAMAGE_RATE = 10.0 #Damage the Mobs do to the Player (maybe give this to mobs?)
	
	if overlapping_mobs.size() > 0:
		#Why Delta? Else we'd loose health per Frame, not per Second!
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta 
		#Progress Bar is linked with health Variable
		$ProgressBar.value = health
		print(health)
		if health <= 0.0:
			health_death.emit()
			print("DEATH")

#function that rotates the weapon along with the players movement
#atan2 math is needed to calc the Vector2 into a rotation angle
func rotate_weapon(direction):#direction param is a Vector2 here
	var angle = atan2(direction.y, direction.x)
	$"player weapon".rotation = angle
	#print("Angle=", angle)#testing angle values
	if angle < -2 or angle >= 1:
		$"player weapon/CharCenter/Weapon".flip_v = true
	else:
		$"player weapon/CharCenter/Weapon".flip_v = false

#function for start of game to move player to start position and show player
func start(pos):
	position = pos
	show()
	#starts the animation
	$AnimatedPlayerSprite.play()
	$PlayerCollisionShape.disabled = false
