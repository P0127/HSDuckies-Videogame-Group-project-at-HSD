extends Area2D #player weapon

const BULLET = preload("res://projectile.tscn")
@onready var spawnpoint = $CharCenter/Icon/BulletSpawnPoint
#yes that var is needed and we cant just reference the BSP node since for some reason
#that creates an error and will act like it doesnt have a position for us to 
#reference even though it very much does

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func shoot():
	if BULLET.can_instantiate():
		var new_bullet = BULLET.instantiate()
		#use global_position cuz position is relative to parent node
		new_bullet.global_position = spawnpoint.global_position
		new_bullet.global_rotation = spawnpoint.global_rotation
		
		#add new bullets as child nodes of the spawnpoint
		spawnpoint.add_child(new_bullet)


#shoots bullet everytime atk speed timer timesout
func _on_attack_speed_timeout():
	shoot()
