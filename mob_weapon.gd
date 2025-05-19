extends Area2D #Mob weapon
#yes I know its weirdly big right now will look into it later with why that much scale is required??


const BULLET = preload("res://mob_projectile.tscn")
@onready var spawnpoint = $CharCenter/Weapon/BulletSpawnPoint
#yes that var is needed and we cant just reference the BSP node since for some reason
#that creates an error and will act like it doesnt have a position for us to 
#reference even though it very much does

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharCenter/Weapon.animation = "sideways"
	#could add a check difficulty here and adjust stats for ranged mob
	#shooting speed or projectile speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
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

func shoot():
	if BULLET.can_instantiate():
		#print("bullet should exist")#testing
		var new_bullet = BULLET.instantiate()
		#use global_position cuz position is relative to parent node
		new_bullet.global_position = spawnpoint.global_position
		new_bullet.global_rotation = spawnpoint.global_rotation
		
		#add new bullets as child nodes of the spawnpoint
		spawnpoint.add_child(new_bullet)



#shoots bullet everytime atk speed timer timesout
func _on_attack_speed_timeout():
	shoot()
