extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBarGrenade 
@onready var grenade_cooldown: Timer = $"../grenade_cooldown"
@onready var grenade_timer: Timer = $"../grenade_timer"
@onready var rich_text_label: RichTextLabel = $GrenadeLabel
@onready var progress_bar_dash: ProgressBar = $ProgressBarDash 
@onready var dash_label: RichTextLabel = $DashLabel 
var dash_cooldown

func _ready() -> void:
	var player = get_parent().get_node("Player")    
	dash_cooldown = player.get_node("Dash_Cooldown")
	progress_bar.value = 0  
	progress_bar.max_value = grenade_timer.wait_time  
	progress_bar.min_value = 0
	progress_bar.visible = true
	
	progress_bar_dash.value = 0  
	progress_bar_dash.max_value = dash_cooldown.wait_time  
	progress_bar_dash.min_value = 0  
	progress_bar_dash.visible = true

	dash_label.text = "Dash Available"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_click") and grenade_timer.time_left <= 0:
		grenade_timer.start()

	if grenade_timer.time_left > 0:
		progress_bar.value = grenade_timer.time_left  
		rich_text_label.text = "Grenade cooldown"
	else:
		progress_bar.value = 0  
		rich_text_label.text = "Grenade Available"

	if Input.is_action_just_pressed("dash") and dash_cooldown.time_left == 0:
		dash_cooldown.start()

	if dash_cooldown.time_left > 0:
		progress_bar_dash.value = dash_cooldown.time_left  
		dash_label.text = "Dash Cooldown"
	else:
		progress_bar_dash.value = 0  
		dash_label.text = "Dash Available"

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
