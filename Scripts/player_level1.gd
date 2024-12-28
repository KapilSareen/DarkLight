extends CharacterBody2D

@onready var healthbar: ColorRect = $ColorRect/healthbar
@onready var dash_cooldown_timer: Timer = $Dash_Cooldown
@onready var knockback: Timer = $Knockback
@onready var enemy: CharacterBody2D = $"../enemy"
@onready var enemy_2: CharacterBody2D = $"../enemy2"

@onready var line_to_enemy: Line2D = $Line2D

var gameOver = false
var HEALTH = 100
var dash_cooldown
var NORMAL_SPEED = 180
var DASH_SPEED = 1000
var SPEED
var is_dashing = false
const DASH_DURATION = 0.5
var dash_timer = false
var health_width
var knockback_timer = 1.2
var knockback_strength = 150
var is_knocked_back = false

enum {
	SURROUND,
	RANDOM,
	HIT,
	RETREAT
}

func _ready() -> void:
	health_width = healthbar.size.x  # Save the original health bar width
	SPEED = NORMAL_SPEED
	dash_cooldown = false
	line_to_enemy.visible = true
	$Dash_Right.emitting = false
	$Dash_Front.emitting = false
	$Dash_Left.emitting = false
	$Dash_Back.emitting = false

func _physics_process(delta: float) -> void:
	if gameOver:
		return

	# Always check if the enemy is valid
	if is_instance_valid(enemy):
		var direction_to_enemy = (enemy.global_position - global_position).normalized()
	# Dash logic
	if Input.is_action_just_pressed("dash") and not is_dashing and not dash_cooldown:
		dash_cooldown = true
		dash_cooldown_timer.start()
		is_dashing = true
		dash_timer = DASH_DURATION

	if is_dashing:
		SPEED = DASH_SPEED
		dash_timer -= delta
		if dash_timer <= 0.0:
			SPEED = NORMAL_SPEED
			is_dashing = false
			$Dash_Right.emitting = false
			$Dash_Front.emitting = false
			$Dash_Left.emitting = false
			$Dash_Back.emitting = false

	# Handle knockback behavior
	if is_knocked_back:
		move_and_slide()
		return

	# Movement
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")

	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	if velocity.length() > 0:
		if !is_dashing:
			velocity = velocity.normalized() * SPEED

	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x != 0:
		if velocity.x > 0:
			$AnimatedSprite2D.animation = "right"
			$Dash_Right.emitting = is_dashing
		else:
			$AnimatedSprite2D.animation = "left"
			$Dash_Left.emitting = is_dashing
	elif velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite2D.animation = "down"
			$Dash_Front.emitting = is_dashing
		else:
			$AnimatedSprite2D.animation = "up"
			$Dash_Back.emitting = is_dashing

	move_and_slide()
	update_enemy_direction()

func _on_attack_radius_body_entered(body: Node2D) -> void:
	if body.has_method("set_state"):
		body.is_in_attack_area = true
		if body.CAN_ATTACK:
			body.state = HIT
			body.is_hitting = false
			body.CAN_ATTACK = false
			body.cooldown.start()
		else:
			body.state = RANDOM

func _on_attack_radius_body_exited(body: Node2D) -> void:
	if body.has_method("set_state"):
		body.is_in_attack_area = false
		body.set_state(SURROUND)

func _on_player_area_body_entered(body: Node2D) -> void:
	take_damage(body)
	
	if body.is_in_group("Enemies"):
		body.set_state(RETREAT)
		set_retreat(body)

func take_damage(body):
	if body.is_in_group("damage_enemy") || body.is_in_group("damage"):
		HEALTH -= body.damage
		body.queue_free()
		# Update health bar size after taking damage
		update_health_bar()

func update_health_bar() -> void:
	# Update health bar width based on the current health
	var health_ratio = HEALTH / 100.0  # Assuming 100 is max health
	healthbar.size.x = health_width * health_ratio
	
	# Optionally, change health bar color based on health percentage
	if HEALTH > 50:
		healthbar.color = Color(0, 1, 0)  # Green
	elif HEALTH > 20:
		healthbar.color = Color(1, 1, 0)  # Yellow
	else:
		healthbar.color = Color(1, 0, 0)  # Red

func set_retreat(body: Node2D) -> void:
	var retreat_direction = (global_position - body.global_position).normalized()
	velocity = retreat_direction * knockback_strength
	if body.is_in_group("Enemies"):
		HEALTH -= 10
		is_knocked_back = true
	$Knockback.start()

func _on_dash_cooldown_timeout():
	dash_cooldown = false

func _on_knockback_timeout() -> void:
	is_knocked_back = false

func update_enemy_direction():
	var closest_enemy: CharacterBody2D = null
	var closest_distance = INF
	
	# Ensure enemy is valid before checking
	if is_instance_valid(enemy):
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		if distance_to_enemy < closest_distance:
			closest_distance = distance_to_enemy
			closest_enemy = enemy
	
	if is_instance_valid(enemy_2):
		var distance_to_enemy2 = global_position.distance_to(enemy_2.global_position)
		if distance_to_enemy2 < closest_distance:
			closest_distance = distance_to_enemy2
			closest_enemy = enemy_2
	
	# If a closest enemy is found, point towards it
	if closest_enemy:
		var direction_to_enemy = (closest_enemy.global_position - global_position).normalized()
		var arrow_start = global_position + Vector2(0, -250)  # Adjust Y-offset as needed
		line_to_enemy.width = 12  
		
		# Update Line2D points for the main part of the arrow
		line_to_enemy.global_position = arrow_start
		line_to_enemy.points = [
			Vector2.ZERO, 
			direction_to_enemy * 95  # Arrow length (adjust as needed)
		]
		
		var arrowhead_length = 25 
		var arrowhead_angle = direction_to_enemy.angle()
		
		var arrowhead_left = line_to_enemy.points[1] - direction_to_enemy.rotated(-PI / 4) * arrowhead_length
		var arrowhead_right = line_to_enemy.points[1] - direction_to_enemy.rotated(PI / 4) * arrowhead_length
		
		line_to_enemy.clear_points()  # Clear previous points
		line_to_enemy.add_point(Vector2.ZERO)
		line_to_enemy.add_point(direction_to_enemy * 95)
		line_to_enemy.add_point(arrowhead_left)
		line_to_enemy.add_point(line_to_enemy.points[1])  
		line_to_enemy.add_point(arrowhead_right)        
		line_to_enemy.visible = true
