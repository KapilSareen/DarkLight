extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("left_mouse_click"):
		#get_tree().change_scene_to_file("res://Scenes/v2.tscn")
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://Scenes/v2.tscn")
	


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/v2.tscn")
	 # Replace with function body.
