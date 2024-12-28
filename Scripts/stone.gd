extends RigidBody2D

@onready var damage_timer: Timer = $damage
var damage = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_timer.start()

func _process(delta: float) -> void:
	pass
	#if get_colliding_bodies().size() > 0:
		#queue_free()
func _on_damage_timeout() -> void:
	queue_free()
