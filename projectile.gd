extends Area2D
#has to be toplevel for it to move independently from parent node
#else if we move another direction bullets will change direction/position with source

var direction#saveslot for direction out projectile will fly
@export var projectile_speed = 500
var travelled_distance = 0 #saveslot for despawning bullets after a while
const MAX_RANGE = 500 #max distance a bullet should live

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * projectile_speed * delta
	
	travelled_distance += projectile_speed * delta
	if travelled_distance > MAX_RANGE:
		queue_free()





func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage
