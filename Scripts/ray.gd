extends RigidBody2D

var damage=10
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()
func _on_body_entered(body: Node) -> void:
	queue_free()
