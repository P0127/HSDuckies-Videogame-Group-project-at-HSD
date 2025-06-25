extends CanvasLayer
@onready var back_b_anim = $BackButton/AnimatedSprite2D



func _ready() -> void:
	$VScrollBar/creditsText.meta_clicked.connect(_on_meta_clicked)
	
func _on_meta_clicked(meta):
	OS.shell_open(meta)

	

func _on_back_button_pressed() -> void:
	back_b_anim.play("pressed")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	GlobalSignals.scene_controller.remove_scene()
	GlobalSignals.scene_controller.change_gui_scene("res://Hud/startscreen.tscn")
