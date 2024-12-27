extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBarGrenade  # Reference to ProgressBar node
@onready var grenade_cooldown: Timer = $"../grenade_cooldown"
@onready var grenade_timer: Timer = $"../grenade_timer"
@onready var rich_text_label: RichTextLabel = $GrenadeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize progress bar settings
	progress_bar.value = 0  # Set the progress bar value to 0 initially
	progress_bar.max_value = grenade_timer.wait_time  # Set max value to the cooldown time of the grenade
	progress_bar.min_value = 0  # Ensure the minimum value is 0
	progress_bar.visible = true  # Make sure the progress bar is visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_click") &&  grenade_timer.time_left <=0:
		grenade_timer.start()  # Start the grenade cooldown timer on click

	if grenade_timer.time_left > 0:
		# Update progress bar value based on remaining time of grenade timer
		progress_bar.value = grenade_timer.time_left

		rich_text_label.text = "Grenade cooldown" 
	else:
		# Reset the progress bar value when grenade is available
		progress_bar.value = 0
		rich_text_label.text = "Grenade Available"  # Optional text display

# Optional rounding function (for text display if you need it)
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
