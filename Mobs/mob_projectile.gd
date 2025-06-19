extends Area2D
#has to be toplevel for it to move independently from parent node
#else if we move another direction bullets will change direction/position with source

@onready var hit_effect = $Particles_Hit

var direction#saveslot for direction out projectile will fly
@export var projectile_speed = 200
var travelled_distance = 0 #saveslot for despawning bullets after a while
const MAX_RANGE = 1250 #max distance a bullet should live
var damage_rate : float = 2.0  + bulletLevel #health amount / 10 the bullets damage
static var bulletLevel  : float = PlayerChracter.level * 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * projectile_speed * delta
	
	travelled_distance += projectile_speed * delta
	if travelled_distance > MAX_RANGE:
		hit_effect.spread = 160
		_lifetime_end()


#when bullet should dissapear
func _lifetime_end():
	hit_effect.set_deferred("emitting", true)
	$Icon.set_deferred("visible", false)
	$CollisionShape2D.set_deferred("disabled", true)
	await hit_effect.finished
	queue_free()


func _on_body_entered(body):
	if(body is not StaticBody2D): #without this we crash when mobs shoot a destroyable object due to single param take_dmg method
		if body.has_method("take_damage"):
			body.take_damage(1, damage_rate)   # delta = 1 to circumvent frame calculation, this is 1-hit damage
	hit_effect.spread = 80
	_lifetime_end()
