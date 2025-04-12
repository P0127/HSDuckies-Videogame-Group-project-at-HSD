extends Camera2D

#Constants dictate the final position of the Zoom-Stage
const ZOOM_DEFAULT : Vector2 = Vector2(1.0 ,1.0)
const ZOOM_MIN : Vector2 = Vector2(0.8, 0.8)
const ZOOM_MAX : Vector2 = Vector2(1.2, 1.2)

#How long the tweening plays for
const TWEEN_DURATION : float = 0.3

#Switches between the 3 Stages
var next_zoom = ZOOM_DEFAULT

#Tween: Animation between Actions, makes Camera movement smooth
var tween : Tween = null

func _process(_delta) -> void:
	#ZOOM IN: Checks if default position comes first, else zooms fully in
	if Input.is_action_just_released('zoom_in'):
		if get_zoom() < ZOOM_DEFAULT:
			next_zoom = ZOOM_DEFAULT
		elif get_zoom() < ZOOM_MAX:
			next_zoom = ZOOM_MAX
		tween = create_tween()
		tween.tween_property(self, "zoom", next_zoom, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)
	
	#ZOOM OUT: Checks if default position comes first, else zooms fully out
	elif Input.is_action_just_released('zoom_out'):
		if get_zoom() > ZOOM_DEFAULT:
			next_zoom = ZOOM_DEFAULT
		elif get_zoom() > ZOOM_MIN:
			next_zoom = ZOOM_MIN
		tween = create_tween()
		tween.tween_property(self, "zoom", next_zoom, TWEEN_DURATION).set_trans(Tween.TRANS_SINE)
