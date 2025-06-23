class_name SceneManager 
extends Node

@export var activ_player: Player
# var activ_player: Player

var scene_dir_path = "res://Map/"


func change_scene(from, to_scene_name: String) -> void:
	activ_player = from.activ_player
	activ_player.get_parent().remove_child(activ_player)
	
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
