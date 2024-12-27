extends Node2D

const V_3 = preload("res://Scenes/v3.tscn")
const SCENE = preload("res://Scenes/scene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var v3=V_3.instantiate()
	get_tree().change_scene_to_file("res://Scenes/v3.tscn")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
