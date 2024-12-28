extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	await get_tree().create_timer(13.3).timeout
	get_tree().change_scene_to_file("res://Scenes/world_level1.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world_level1.tscn")
	
