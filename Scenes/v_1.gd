extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	await get_tree().create_timer(7).timeout
	get_tree().change_scene_to_file("res://Scenes/v2.tscn")
