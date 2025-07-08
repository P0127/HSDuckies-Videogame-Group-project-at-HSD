extends Area2D

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

func manage_PlayerCamera_panning (body : Node2D, panEnabled : bool = false):
	if body.has_node("PlayerCamera"):
		body.get_node("PlayerCamera").position_smoothing_enabled = panEnabled

func show_elevator() -> void:
	if (GlobalSignals.duck_counter.ducks_collected >= 19) && (!elevator.visible):
		elevator.show()
