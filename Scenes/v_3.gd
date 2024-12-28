extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("left_mouse_click"):
		#get_tree().change_scene_to_file("res://Scenes/v4.tscn")
	await get_tree().create_timer(13.6).timeout
	get_tree().change_scene_to_file("res://Scenes/v4.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/v4.tscn")
	
