extends Area2D #player weapon

var standard_firerate_waittime : float = 0.50 #Waittime before it's shot again, the lower the better
var firerate_waittime := standard_firerate_waittime
const FIRERATE_WATTIME_ON_LEVELUP : float = 0.02
var bullet_size : float = 1 #Standard scaling at the start
const BULLET_SIZE_ON_LEVELUP : float = 0.1 #How much size increase on levelUp

const BULLET = preload("res://Weapon/projectile.tscn")
@onready var spawnpoint = $CharCenter/Weapon/BulletSpawnPoint
#yes that var is needed and we cant just reference the BSP node since for some reason
#that creates an error and will act like it doesnt have a position for us to 
#reference even though it very much does

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharCenter/Weapon.animation = "sideways"
	$"attack speed".wait_time = firerate_waittime
	
	#Global Timer timeouts to reset stats
	GlobalSignals.timerFirerate.connect("timeout", _on_global_firerate_timeout)
	GlobalSignals.duck_collected_signal.connect(_levelUp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#Switches Animations depending on the rotation
	match int(rotation_degrees):
		90, -90:
			$CharCenter/Weapon.animation = "topdown"
		_:
			$CharCenter/Weapon.animation = "sideways"
	
	#Flips Sprites depending on rotation (position to Player)
	match int(rotation_degrees):
		-135, 180, 135:
			$CharCenter/Weapon.flip_v = true
		_:
			$CharCenter/Weapon.flip_v = false
	
	_spawnpoint_correction()

func shoot():
	if BULLET.can_instantiate():
		var new_bullet = BULLET.instantiate()
		#use global_position cuz position is relative to parent node
		new_bullet.global_position = spawnpoint.global_position
		new_bullet.global_rotation = spawnpoint.global_rotation
		new_bullet.apply_scale(Vector2(bullet_size, bullet_size))
		
		#add new bullets as child nodes of the spawnpoint
		spawnpoint.add_child(new_bullet)

#Spawnpoint does not flip together with weapon
func _spawnpoint_correction():
	match int(rotation_degrees):
		90, -90:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50,0)
		-135, 180, 135:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50, 18)
		_:
			$CharCenter/Weapon/BulletSpawnPoint.position = Vector2(50, -18)
			

#shoots bullet everytime atk speed timer timesout
func _on_attack_speed_timeout():
	shoot()

#ticks up firerate on item pickup
func boost_firerate_collected(changerate : float):
	$"attack speed".wait_time = (firerate_waittime / changerate)

#resets on global effect timer timeout
func _on_global_firerate_timeout():
	$"attack speed".wait_time = standard_firerate_waittime

func _levelUp ():
	standard_firerate_waittime -= FIRERATE_WATTIME_ON_LEVELUP #adds 0.1 at a time
	$"attack speed".wait_time -= FIRERATE_WATTIME_ON_LEVELUP #else only adds to current firerate once boost runs out
	bullet_size += BULLET_SIZE_ON_LEVELUP #Bullets get larger
