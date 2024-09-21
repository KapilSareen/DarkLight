extends CharacterBody2D

const SPEED = 60
const RANDOM_SPEED = 160
const STONE_SPEED=50
var motion=Vector2.ZERO
var player= null
var CAN_ATTACK=true
var is_in_attack_area=false

var is_hitting= false

#@onready var stone: Node2D = $"."
var stone = preload("res://scenes/stone.tscn")

@onready var ray_1: RayCast2D = $rays/ray1
@onready var ray_2: RayCast2D = $rays/ray2
@onready var ray_3: RayCast2D = $rays/ray3
@onready var ray_4: RayCast2D = $rays/ray4


@onready var ray_1_slant: RayCast2D = $rays_slant/ray1
@onready var ray_2_slant: RayCast2D = $rays_slant/ray2
@onready var ray_3_slant: RayCast2D = $rays_slant/ray3
@onready var ray_4_slant: RayCast2D = $rays_slant/ray4


@onready var enemy: CharacterBody2D = $"."
@onready var Player: CharacterBody2D = $"../Player"
@onready var attack_timer: Timer = $AttackTimer
@onready var cooldown: Timer = $Cooldown
@onready var random_movement_timer: Timer = $RandomMovement

var random_inward_outward = 0.0
var random_tangential_speed = 0.0

var randomnum

enum {
	SURROUND,
	RANDOM,
	HIT,
	RETREAT
}

var state = RANDOM

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	player=Player
	random_movement_timer.start()
  

func _physics_process(delta):

	$AnimatedSprite2D.play()
	if abs(velocity.y) > abs(velocity.x):
		if velocity.y > 0:
			$AnimatedSprite2D.animation = "down"
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "up"
	else:
		if velocity.x > 0:
			$AnimatedSprite2D.animation = "right"
		if velocity.x < 0:
			$AnimatedSprite2D.animation = "left"
	match state:
		SURROUND:
			move(get_circle_position(randomnum), delta)
			print(SURROUND)
		RANDOM:
			print("IS IN" )
			print(is_in_attack_area)
			if is_in_attack_area:
				state=HIT
			print("RANDOM")
			move_random(player.global_position, delta)

		HIT:
			print("HIT")
			move_random(player.global_position, delta)
			if ! is_hitting:
				hit()
				is_hitting=true
		
		RETREAT:
			retreat(player.global_position,delta,-1)
			print("RETREAT")

func move_random(target, delta):
	var player_direction = (target - global_position).normalized()
	var inward_outward_movement = player_direction * random_inward_outward * delta
	var side_direction = Vector2(-player_direction.y, player_direction.x)
	var tangential_movement = side_direction * random_tangential_speed * delta
	velocity = (inward_outward_movement + tangential_movement) * RANDOM_SPEED * 25 
	print("Velocity:", velocity)
	move_and_slide()



	
func retreat(target,delta, sign):
	var direction = sign * (target - global_position).normalized() 
	var desired_velocity =  direction * SPEED * 2
	var steering = desired_velocity
	velocity = steering
	move_and_slide()

func move(target, delta):
	var direction = (target - global_position).normalized() 
	var desired_velocity =  direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	print(velocity)
	move_and_slide()

func set_state(new_state):
	state = new_state

func get_circle_position(random):
	if player:
		var kill_circle_centre = player.global_position
		var radius = 180
		
		var angle = random * PI * 2;
		var x = kill_circle_centre.x + cos(angle) * radius;
		var y = kill_circle_centre.y + sin(angle) * radius;

		return Vector2(x, y)


func _on_AttackTimer_timeout():
	print("Timed out")


func launch_stone(directions):
	for i in range(len(directions)):
		var new_stone=stone.instantiate()
		add_child(new_stone)
		new_stone.position = directions[i].target_position
		var direction = (directions[i].target_position).normalized()
		new_stone.apply_impulse(direction*180)

func hit():
	print("Hitting")
	var directions=[]
	directions.append(ray_1)
	directions.append(ray_2)
	directions.append(ray_3)
	directions.append(ray_4)
	launch_stone(directions)
	
	await get_tree().create_timer(3).timeout
	
	directions=[]
	directions.append(ray_1_slant)
	directions.append(ray_2_slant)
	directions.append(ray_3_slant)
	directions.append(ray_4_slant)
	launch_stone(directions)



func _on_random_movement_timeout() -> void:
	random_inward_outward = randf_range(-0.25, 0.5) 
	random_tangential_speed = randf_range(-1.5, 1.5)
	print("New random movement generated: inward/outward:", random_inward_outward, "tangential:", random_tangential_speed)


func _on_cooldown_timeout() -> void:
	CAN_ATTACK=true
	is_hitting=false
	if is_in_attack_area:
		state=HIT
	
