class_name AufzugTrigger
extends Area2D

@export var connected_scene: String
var scene_folder = "res://Map/"

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		scene_manager.change_scene(get_owner(), connected_scene)
