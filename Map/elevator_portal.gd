extends Area2D


# Flag to ensure the elevator dialogue only triggers once
var elevator_dialog_triggered := false

@onready var elevator : TileMapLayer = $"../Aufzug"

func _ready() -> void:
	GlobalSignals.duck_collected_signal.connect(show_elevator)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		manage_PlayerCamera_panning(body, false)
		body.set_position($destinationPoint.global_position) # teleport to the Marker2D ($destinationPoint) on the other map part
		await get_tree().create_timer(0.05).timeout
		manage_PlayerCamera_panning(body, true)
		
		##Going to the 2nd floor will toggle mobs dropping ducks and natural spawns
		GlobalSignals.toggle_mob_drops.emit()
		GlobalSignals.toggle_natural_spawns.emit()

		# Start dialogue after reaching the second floor, if not already shown
		if not elevator_dialog_triggered:
			elevator_dialog_triggered = true
			GlobalSignals.dialogue_start.emit("res://CutScene/Dialogue/2.Etage.json")


func manage_PlayerCamera_panning (body : Node2D, panEnabled : bool = false):
	if body.has_node("PlayerCamera"):
		body.get_node("PlayerCamera").position_smoothing_enabled = panEnabled

func show_elevator() -> void:
	if (GlobalSignals.duck_counter.ducks_collected >= 19) && (!elevator.visible):
		elevator.show()
