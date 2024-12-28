extends PointLight2D
#@onready var spotlight_cooldown: Timer = $Spotlight_cooldown 
@onready var player: CharacterBody2D = $".."
const GROWTH_RATE = 10.0  # Speed of scaling up
const DECREASE_RATE = 1.0  # Speed of scaling down
const MAX_SCALE = 5.0  # Maximum allowable scale
const ORIGINAL_SCALE = 1.0  # Original (starting) scale
const GROW_TIME = 1.0
const SHRINK_TIME = 10.0  

# Variables to handle scaling states and timers
var is_scaling_down = false  # A flag indicating if scaling down is active
var is_scaling_up = false  # A flag indicating if scaling up is active
var scaling_timer = 0.0  # Timer for scaling up and down
var cooldown = false
#const DECREASE_RATE = 1.0  # Speed of light dimming when game over
#const ORIGINAL_SCALE = 1.0  # Original (starting) scale

# Variables for state management
var is_dimming = false  # A flag indicating if dimming is active

#const GROWTH_RATE = 10.0  # Speed of scaling up
#const DECREASE_RATE = 1.0  # Speed of scaling down
#const MAX_SCALE = 5.0  # Maximum allowable scale
#const ORIGINAL_SCALE = 1.0  # Original (starting) scale
#const GROW_TIME = 1.0
#const SHRINK_TIME = 10.0  

# Constants for growth, decrease, max, and initial scale sizes
#const GROWTH_RATE = 10.0  # Speed of scaling up
#const MAX_SCALE = 5.0  # Maximum allowable scale
#const GROW_TIME = 1.0
#const SHRINK_TIME = 10.0  

# Variables to handle scaling states and timers
#var is_scaling_down = false  # A flag indicating if scaling down is active
#var is_scaling_up = false  # A flag indicating if scaling up is active
#var scaling_timer = 0.0  # Timer for scaling up and down
#var cooldown = false
func _ready():
	# Set the initial scale of the PointLight2D when the scene starts
	self.scale = Vector2(ORIGINAL_SCALE, ORIGINAL_SCALE)

func _process(delta):
	# Check if the game is over
	if player.gameOver and not is_dimming:
		is_dimming = true  # Start dimming the light
	
	# Gradually dim the light if dimming is active
	if is_dimming:
		# Slowly reduce the energy (light intensity)
		energy = move_toward(energy, 0.0, DECREASE_RATE * delta)
		
		# Optionally, also reduce scale if desired
		self.scale = self.scale.move_toward(Vector2(0.0, 0.0), DECREASE_RATE * delta)
		
		# Stop dimming once the light is fully dimmed
		if energy == 0.0 and self.scale == Vector2(0.0, 0.0):
			is_dimming = false  # Stop further processing	# Start scaling up when the "ui_accept" key is pressed once
	if Input.is_action_just_pressed("ui_accept") and not cooldown: 
		#cooldown = true
		is_scaling_up = true  # Enable scaling up
		is_scaling_down = false  # Disable scaling down
		scaling_timer = GROW_TIME  # Set the timer for the scaling up process
	
	# If scaling up is active, gradually increase the scale over time
	if is_scaling_up:
		scaling_timer -= delta  # Decrease the scaling timer

		# Gradually increase the scale over time
		self.scale = self.scale.move_toward(Vector2(MAX_SCALE, MAX_SCALE), GROWTH_RATE * delta)

		# Stop scaling up once the maximum scale is reached or timer runs out
		if scaling_timer <= 0.0 or self.scale == Vector2(MAX_SCALE, MAX_SCALE):
			#spotlight_cooldown.start()
			self.scale = Vector2(MAX_SCALE, MAX_SCALE)  # Ensure final scale is exact
			is_scaling_up = false  # Stop the scaling up process
			is_scaling_down = true  # Automatically start scaling down

	# When the "ui_accept" key is released, start the scaling down process
	if Input.is_action_just_released("ui_accept"):
		is_scaling_down = true  # Enable scaling down
		scaling_timer = SHRINK_TIME  # Reset the timer for scaling down

	# If scaling down is active, gradually decrease the scale over time
	if is_scaling_down:
		scaling_timer -= delta  # Decrease the scaling timer

		# Gradually move the scale back to the original size over time
		self.scale = self.scale.move_toward(Vector2(ORIGINAL_SCALE, ORIGINAL_SCALE), DECREASE_RATE * delta)

		# Stop scaling down once the timer runs out or the original size is reached
		if scaling_timer <= 0.0 or self.scale == Vector2(ORIGINAL_SCALE, ORIGINAL_SCALE):
			self.scale = Vector2(ORIGINAL_SCALE, ORIGINAL_SCALE)  # Ensure final scale is exact
			is_scaling_down = false  # Stop the scaling down process
