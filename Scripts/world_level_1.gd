extends Node2D

@onready var enemy: CharacterBody2D = $enemy
@onready var enemy_2: CharacterBody2D = $enemy2

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
var gameOver = false
var can_grenade = true
var grenade_scene = preload("res://Scenes/grenade_2.tscn")
var Click_Position = Vector2(0,0)
var final_position = Vector2(0,0)
var throw_force = 180
@onready var player = $Player
@onready var grenade_cooldown: Timer = $grenade_cooldown

var ray_scene = preload("res://Scenes/ray.tscn")
var m
var mid
var time = 0
var r = false
var val = 0
var max_radius = 1200

func _ready() -> void:
	audio_stream_player_2d.play()

var grenade

func _process(delta):
	if gameOver:
		return
	
	var pos = player.global_position
	val += delta
	
	# Grenade throw logic
	if Input.is_action_just_pressed("left_mouse_click") && can_grenade:
		can_grenade = false
		grenade_cooldown.start()
		Click_Position = get_global_mouse_position()
		final_position = Click_Position

		m = (final_position + 3 * pos) / 4
		m.y = m.y - 0.5 * abs(final_position.y - pos.y) - 0.5 * abs(final_position.x - pos.x)
		grenade = grenade_scene.instantiate()
		audio_stream_player_2d_2.play()
		add_child(grenade)
		grenade.position = pos
		time = 0

	# Grenade movement logic
	if m && grenade:
		grenade.position = bezeir(time, pos)
		time += delta
		if time > 0.5:
			m = 0
			time = 0

	# Damage enemies on grenade explosion
	if is_instance_valid(grenade):
		var radius = 200
		var grenade_position = grenade.position
		
		# Check damage for both enemies before freeing grenade
		var damaged = false
		
		# Damage Enemy 1
		var distance_enemy1 = enemy.position.distance_to(grenade_position)
		if distance_enemy1 < radius:
			enemy.HEALTH -= grenade.damage
			damaged = true
		
		# Damage Enemy 2
		var distance_enemy2 = enemy_2.position.distance_to(grenade_position)
		if distance_enemy2 < radius:
			enemy_2.HEALTH -= grenade.damage
			damaged = true
		
		# Only free grenade after processing all damage
		if damaged:
			grenade.queue_free()
			grenade = null

func bezeir(t, pos):
	t = t * 2
	var p1 = pos.lerp(m, t)
	var p2 = m.lerp(final_position, t)
	var r = p1.lerp(p2, t)
	return r

func get_final_position(player_pos: Vector2, click_pos: Vector2, max_radius: float) -> Vector2:
	var distance = player_pos.distance_to(click_pos)
	if distance <= max_radius:
		return click_pos 
	else:
		var direction = (click_pos - player_pos).normalized()
		return player_pos + direction * max_radius  

func _on_grenade_cooldown_timeout() -> void:
	can_grenade = true
	
func hit():
	var ray_node = ray_scene.instantiate()
	add_child(ray_node)
	ray_node.position = enemy.position
	var direction = (player.position - ray_node.position).normalized()
	var angle = direction.angle()
	ray_node.rotation = angle
	ray_node.apply_impulse(direction * 100 * 4)
