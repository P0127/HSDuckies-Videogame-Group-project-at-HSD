extends Area2D #Mob weapon
#yes I know its weirdly big right now will look into it later with why that much scale is required??

const STANDARD_FIRERATE_WAITTIME : float = 2 #Waittime in seconds before it's shot again

const BULLET = preload("res://Mobs/mob_projectile.tscn")

#Every weapon needs to know to which mob it belongs and uses this to spawn the bullets
@export var mob : CharacterBody2D
@onready var spawnpoint = $CharCenter/Weapon/BulletSpawnPoint

var fire_status = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharCenter/Weapon.animation = "sideways"
	#could add a check difficulty here and adjust stats for ranged mob
	#shooting speed or projectile speed
	$attack_speed.wait_time = STANDARD_FIRERATE_WAITTIME


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#will prob remove this later and make it invisble or sth
	#however might be a problem for visibility so we'll see
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

func shoot():
	if BULLET.can_instantiate():
		#print("bullet should exist")#testing
		var new_bullet = BULLET.instantiate()
		#use global_position cuz position is relative to parent node
		new_bullet.global_position = spawnpoint.global_position
		new_bullet.global_rotation = spawnpoint.global_rotation
		
		#add new bullets as child nodes of the spawnpoint
		mob.add_child(new_bullet)

func attack(status : bool):
	$attack_speed.set_paused(!status)

#shoots bullet everytime atk speed timer timesout
func _on_attack_speed_timeout():
	if(fire_status):
		shoot()

func change_firerate(firerate : float, change : bool):
	if change:
		$attack_speed.wait_time = firerate
	else:
		$attack_speed.wait_time = STANDARD_FIRERATE_WAITTIME

func swap_fire_status():
	fire_status = !fire_status
