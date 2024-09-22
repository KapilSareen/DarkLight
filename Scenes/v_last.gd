extends Node2D

const V_LAST = preload("res://Scenes/v_last.tscn")
const WORLD_LEVEL_1 = preload("res://Scenes/world_level1.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


#
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://Scenes/world_level1.tscn")
