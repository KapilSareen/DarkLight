extends RigidBody2D

var damage=10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.75).timeout
	queue_free()
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


#func _on_body_entered(body: Node) -> void:
	#queue_free()
