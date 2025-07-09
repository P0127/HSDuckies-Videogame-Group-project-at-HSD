extends Area2D 
#player weapon

## STATS
var standard_firerate_waittime : float = 0.50 #Waittime before it's shot again, the lower the better
var firerate_waittime := standard_firerate_waittime #present firerate (can be influenced by effects)
const FIRERATE_WATTIME_ON_LEVELUP : float = 0.04 #Change of Firerate on LevelUp
var bullet_size : float = 1 #Standard scaling at the start
const BULLET_SIZE_ON_LEVELUP : float = 0.2 #How much size increase on levelUp

var pause : bool = false #If shooting bullets needs to be paused

## SCENES
const BULLET = preload("res://Weapon/projectile.tscn")
@onready var spawnpoint = $CharCenter/Weapon/BulletSpawnPoint

## FUNCTIONS PRESETS
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharCenter/Weapon.animation = "sideways"
	$"attack speed".wait_time = firerate_waittime
	
	#Global Timer timeouts to reset stats
	GlobalSignals.timerFirerate.connect("timeout", _on_global_firerate_timeout)
	#Increases firerate on levelUp
	GlobalSignals.duck_collected_levelUp.connect(_levelUp)


@warning_ignore("unused_parameter")
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#Switches Animations depending on the rotation
	match int(rotation_degrees):
		90, -90:
			$CharCenter/Weapon.animation = "topdown"
		_:
			$CharCenter/Weapon.animation = "sideways"
			
	#Flips sprite if we are aiming towards the left
	if (rotation_degrees < -90 or rotation_degrees > 90):
		$CharCenter/Weapon.flip_v = true
	else:
		$CharCenter/Weapon.flip_v = false
	
	_spawnpoint_correction()
	


## FUNCTIONS
#Spawns Bullet on global position
func shoot():
	if BULLET.can_instantiate():
		var new_bullet = BULLET.instantiate()
		#use global_position cuz position is relative to parent node
		new_bullet.global_position = spawnpoint.global_position
		new_bullet.global_rotation = spawnpoint.global_rotation
		#Changes size dependant on level, determined on initialisation
		new_bullet.apply_scale(Vector2(bullet_size, bullet_size))
		
		#add new bullets as child nodes of the spawnpoint
		spawnpoint.add_child(new_bullet)
		
		#Play soundeffect
		$CharCenter/Weapon/ShootSound.play()

#Spawnpoint does not flip together with weapon
func _spawnpoint_correction():
	match int(rotation_degrees):
		90, -90:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50,0)
		-135, 180, 135:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50, 18)
		_:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50, -18)

#Shoots bullet everytime atk speed timer timesout
func _on_attack_speed_timeout():
	if not pause:
		shoot()

## FUNCTIONS STAT CHANGES
#Reduces firerate on item pickup
func boost_firerate_collected(changerate : float):
	$"attack speed".wait_time = (firerate_waittime / changerate)

#resets on global effect timer timeout
func _on_global_firerate_timeout():
	$"attack speed".wait_time = standard_firerate_waittime

#Firerate change on LevelUp, works while Effect is active
func _levelUp ():
	standard_firerate_waittime -= FIRERATE_WATTIME_ON_LEVELUP #removes waiting time between shots
	$"attack speed".wait_time -= FIRERATE_WATTIME_ON_LEVELUP #else only adds to current firerate once boost runs out
	print(standard_firerate_waittime)
	bullet_size += BULLET_SIZE_ON_LEVELUP #Bullets get larger
