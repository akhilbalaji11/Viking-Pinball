extends Node2D

# This logic and the associated graphic resources simulate a low-res dot matrix display.

# We're simulating a display with a resolution of 128x32.
const DMD_WIDTH = 128
const DMD_HEIGHT = 32
const DMD_RECT = Rect2(-64, -16, 128, 32)
const BLANK_COLOR = Color(0, 0, 0)

# The display now only shows text
enum {MODE_TEXT}

# These are the different items the display can show.
enum {
	DISPLAY_LANE_HUNTED,
	DISPLAY_X2,
	DISPLAY_X4,
	DISPLAY_X8,
	DISPLAY_LOCKED,
	DISPLAY_BALL_SAVED,
	DISPLAY_LANE_REWARD,
	DISPLAY_TITLE,
	DISPLAY_TARGET_HUNT,
	DISPLAY_LANE_HUNT,
	DISPLAY_WIZARD,
	DISPLAY_GAME_OVER,
	DISPLAY_EXTRA_BALL,
	DISPLAY_BALL_LOST,
	DISPLAY_MULTIBALL,
	DISPLAY_TARGET_BANK_REWARD,
	DISPLAY_LOOP,
	DISPLAY_JACKPOT,
	DISPLAY_WIZARD_JACKPOT,
	DISPLAY_TARGET_HUNT_REWARD,
	DISPLAY_BUMPER_REWARD,
	DISPLAY_LANE_HUNT_REWARD,
	DISPLAY_SKILL_SHOT,
	DISPLAY_SCORE,
	DISPLAY_FINAL_SCORE,
	DISPLAY_FINAL_RESTART,
	DISPLAY_HELP_KEY,
	DISPLAY_START_KEY,
	DISPLAY_LANE_HUNT_RULES,
	DISPLAY_TARGET_HUNT_RULES,
	DISPLAY_BUMPER_PROGRESS,
	DISPLAY_LANE_HUNT_EXPIRED,
	DISPLAY_TARGET_HUNT_EXPIRED,
	DISPLAY_HIGH_SCORE,
	DISPLAY_NEW_HIGH_SCORE,
	DISPLAY_LANE_BONUS,
	DISPLAY_LOOP_BONUS,
	DISPLAY_TARGET_BONUS,
	DISPLAY_TOTAL_BONUS,
	DISPLAY_WIZARD_READY}

# This dictionary gives the duration of each display, in seconds.
const DISPLAY_TIME = {
	DISPLAY_LANE_HUNTED: 2.0,
	DISPLAY_X2: 2.0,
	DISPLAY_X4: 2.0,
	DISPLAY_X8: 2.0,
	DISPLAY_LOCKED: 3.0,
	DISPLAY_BALL_SAVED: 2.0,
	DISPLAY_LANE_REWARD: 3.0,
	DISPLAY_TITLE: 2.0,
	DISPLAY_LANE_HUNT: 2.0,
	DISPLAY_TARGET_HUNT: 2.0,
	DISPLAY_WIZARD: 3.0,
	DISPLAY_GAME_OVER: 2.0,
	DISPLAY_EXTRA_BALL: 3.0,
	DISPLAY_BALL_LOST: 2.0,
	DISPLAY_MULTIBALL: 3.0,
	DISPLAY_TARGET_BANK_REWARD: 2.0,
	DISPLAY_LOOP: 2.0,
	DISPLAY_JACKPOT: 3.0,
	DISPLAY_WIZARD_JACKPOT: 2.0,
	DISPLAY_SCORE: 3.0,
	DISPLAY_FINAL_SCORE: 3.0,
	DISPLAY_FINAL_RESTART: 2.0,
	DISPLAY_HELP_KEY: 2.0,
	DISPLAY_START_KEY: 2.0,
	DISPLAY_LANE_HUNT_RULES: 2.0,
	DISPLAY_LANE_HUNT_REWARD: 3.0,
	DISPLAY_SKILL_SHOT: 2.0,
	DISPLAY_TARGET_HUNT_RULES: 2.0,
	DISPLAY_TARGET_HUNT_REWARD: 3.0,
	DISPLAY_BUMPER_PROGRESS: 3.0,
	DISPLAY_BUMPER_REWARD: 3.0,
	DISPLAY_LANE_HUNT_EXPIRED: 3.0,
	DISPLAY_TARGET_HUNT_EXPIRED: 3.0,
	DISPLAY_HIGH_SCORE: 2.0,
	DISPLAY_NEW_HIGH_SCORE: 3.0,
	DISPLAY_LANE_BONUS: 1.0,
	DISPLAY_LOOP_BONUS: 1.0,
	DISPLAY_TARGET_BONUS: 1.0,
	DISPLAY_TOTAL_BONUS: 2.0,
	DISPLAY_WIZARD_READY: 3.0}

# This dictionary gives the priority of each display. A low-priority
# display will not interrupt a high-priority display.
const DISPLAY_PRIORITY = {
	DISPLAY_LANE_HUNTED: 0,
	DISPLAY_X2: 3,
	DISPLAY_X4: 3,
	DISPLAY_X8: 3,
	DISPLAY_LOCKED: 0,
	DISPLAY_BALL_SAVED: 10,
	DISPLAY_LANE_REWARD: 1,
	DISPLAY_TITLE: 0,
	DISPLAY_LANE_HUNT: 3,
	DISPLAY_TARGET_HUNT: 3,
	DISPLAY_WIZARD: 5,
	DISPLAY_GAME_OVER: 0,
	DISPLAY_EXTRA_BALL: 10,
	DISPLAY_BALL_LOST: 50,
	DISPLAY_MULTIBALL: 5,
	DISPLAY_TARGET_BANK_REWARD: 0,
	DISPLAY_LOOP: 0,
	DISPLAY_JACKPOT: 0,
	DISPLAY_WIZARD_JACKPOT: 3,
	DISPLAY_SCORE: 0,
	DISPLAY_FINAL_SCORE: 0,
	DISPLAY_FINAL_RESTART: 0,
	DISPLAY_HELP_KEY: 0,
	DISPLAY_START_KEY: 0,
	DISPLAY_LANE_HUNT_RULES: 0,
	DISPLAY_LANE_HUNT_REWARD: 3,
	DISPLAY_SKILL_SHOT: 0,
	DISPLAY_TARGET_HUNT_RULES: 0,
	DISPLAY_TARGET_HUNT_REWARD: 3,
	DISPLAY_BUMPER_PROGRESS: 0,
	DISPLAY_BUMPER_REWARD: 3,
	DISPLAY_LANE_HUNT_EXPIRED: 3,
	DISPLAY_TARGET_HUNT_EXPIRED: 3,
	DISPLAY_HIGH_SCORE: 0,
	DISPLAY_NEW_HIGH_SCORE: 0,
	DISPLAY_LANE_BONUS: 0,
	DISPLAY_LOOP_BONUS: 0,
	DISPLAY_TARGET_BONUS: 0,
	DISPLAY_TOTAL_BONUS: 0,
	DISPLAY_WIZARD_READY: 3}

# Certain displays appear in loops or in fixed sequences.
const START_SEQ = [DISPLAY_TITLE, DISPLAY_HELP_KEY, DISPLAY_START_KEY, DISPLAY_HIGH_SCORE]
const ATTRACT_SEQ = [DISPLAY_FINAL_SCORE, DISPLAY_TITLE, DISPLAY_HELP_KEY, DISPLAY_START_KEY, DISPLAY_HIGH_SCORE]
const LANE_HUNT_SEQ = [DISPLAY_LANE_HUNT, DISPLAY_LANE_HUNT_RULES]
const TARGET_HUNT_SEQ = [DISPLAY_TARGET_HUNT, DISPLAY_TARGET_HUNT_RULES]
const BONUS_SEQ = [DISPLAY_LANE_BONUS, DISPLAY_LOOP_BONUS, DISPLAY_TARGET_BONUS, DISPLAY_TOTAL_BONUS]

var font
var font_texture = preload("res://graphics/font.png")
var upper_text
var lower_text
var upper_draw = Vector2(0, -14)
var lower_draw = Vector2(0, 2)
var mode = MODE_TEXT
var displaying = -1
var parameters = {}
var repeat = false
var sequence = []
var sequence_index = 0
var paused = false
var lower_text_scale = Vector2(0.7, 0.7)  # Scale factor for lower text (adjust as needed)

# There is probably a better way to do this, but this didn't require much
# thought, and it works. We're mapping characters to specific positions
# within the font bitmap.
func _ready():
	font = BitmapFont.new()
	font.add_texture(font_texture)
	font.set_height(13)
	
	font.add_char(KEY_A, 0, Rect2(0, 0, 8, 12))
	font.add_char(KEY_B, 0, Rect2(8, 0, 8, 12))
	font.add_char(KEY_C, 0, Rect2(16, 0, 8, 12))
	font.add_char(KEY_D, 0, Rect2(24, 0, 8, 12))
	font.add_char(KEY_E, 0, Rect2(32, 0, 8, 12))
	font.add_char(KEY_F, 0, Rect2(40, 0, 8, 12))
	font.add_char(KEY_G, 0, Rect2(48, 0, 8, 12))
	
	font.add_char(KEY_H, 0, Rect2(0, 12, 8, 12))
	font.add_char(KEY_I, 0, Rect2(8, 12, 8, 12))
	font.add_char(KEY_J, 0, Rect2(16, 12, 8, 12))
	font.add_char(KEY_K, 0, Rect2(24, 12, 8, 12))
	font.add_char(KEY_L, 0, Rect2(32, 12, 8, 12))
	font.add_char(KEY_M, 0, Rect2(40, 12, 8, 12))
	font.add_char(KEY_N, 0, Rect2(48, 12, 8, 12))

	font.add_char(KEY_O, 0, Rect2(0, 24, 8, 12))
	font.add_char(KEY_P, 0, Rect2(8, 24, 8, 12))
	font.add_char(KEY_Q, 0, Rect2(16, 24, 8, 12))
	font.add_char(KEY_R, 0, Rect2(24, 24, 8, 12))
	font.add_char(KEY_S, 0, Rect2(32, 24, 8, 12))
	font.add_char(KEY_T, 0, Rect2(40, 24, 8, 12))
	font.add_char(KEY_U, 0, Rect2(48, 24, 8, 12))

	font.add_char(KEY_V, 0, Rect2(0, 36, 8, 12))
	font.add_char(KEY_W, 0, Rect2(8, 36, 8, 12))
	font.add_char(KEY_X, 0, Rect2(16, 36, 8, 12))
	font.add_char(KEY_Y, 0, Rect2(24, 36, 8, 12))
	font.add_char(KEY_Z, 0, Rect2(32, 36, 8, 12))
	font.add_char(KEY_0, 0, Rect2(40, 36, 8, 12))
	font.add_char(KEY_1, 0, Rect2(48, 36, 8, 12))

	font.add_char(KEY_2, 0, Rect2(0, 48, 8, 12))
	font.add_char(KEY_3, 0, Rect2(8, 48, 8, 12))
	font.add_char(KEY_4, 0, Rect2(16, 48, 8, 12))
	font.add_char(KEY_5, 0, Rect2(24, 48, 8, 12))
	font.add_char(KEY_6, 0, Rect2(32, 48, 8, 12))
	font.add_char(KEY_7, 0, Rect2(40, 48, 8, 12))
	font.add_char(KEY_8, 0, Rect2(48, 48, 8, 12))

	font.add_char(KEY_9, 0, Rect2(0, 60, 8, 12))
	font.add_char(KEY_COMMA, 0, Rect2(8, 60, 8, 12))
	font.add_char(KEY_COLON, 0, Rect2(16, 60, 8, 12))
	font.add_char(KEY_EXCLAM, 0, Rect2(24, 60, 8, 12))
	
	font.add_char(KEY_SPACE, 0, Rect2(48, 72, 8, 12))

func _draw():
	draw_rect(DMD_RECT, BLANK_COLOR, true)
	if paused:
		# If the game is paused, just draw the pause text.
		draw_string(font, Vector2(get_starting_x("PAUSED"), upper_draw.y), "PAUSED")
		
		# Draw the lower text with a transform to scale it
		var transform = Transform2D()
		transform = transform.scaled(lower_text_scale)
		transform.origin = Vector2(get_starting_x_small("SPACE: RESUME ESC: QUIT"), lower_draw.y)
		draw_set_transform_matrix(transform)
		draw_string(font, Vector2.ZERO, "SPACE: RESUME ESC: QUIT")
		draw_set_transform_matrix(Transform2D()) # Reset transform
	else:
		# Draw upper text normally
		draw_string(font, upper_draw, upper_text)
		
		# Draw lower text with scaling if it exists
		if lower_text:
			var transform = Transform2D()
			transform = transform.scaled(lower_text_scale)
			transform.origin = Vector2(get_starting_x_small(lower_text), lower_draw.y)
			draw_set_transform_matrix(transform)
			draw_string(font, Vector2.ZERO, lower_text)
			draw_set_transform_matrix(Transform2D()) # Reset transform

# Set the pause mode for the display.
func set_paused(is_paused):
	paused = is_paused
	update()

# For a given string, determine the leftmost X coordinate.
func get_starting_x(text):
	return 0 - ((len(text) * 8) / 2)

# For a given string, determine the leftmost X coordinate for scaled text.
func get_starting_x_small(text):
	return 0 - ((len(text) * 8 * lower_text_scale.x) / 2)

# Set the text for the top line of the display.
func set_upper_text(new_text):
	upper_text = new_text
	upper_draw.x = get_starting_x(upper_text)
	update()

# Set the text for the bottom line of the display.
func set_lower_text(new_text):
	lower_text = new_text
	update()

# Some text messages include parameters, such as score or ball number.
func set_parameter(param_name, param_value):
	parameters[param_name] = param_value
	format_text()

# Concatenate a quantity and a noun, and make the noun plural if necessary.
func pluralize(quantity, word):
	if quantity != 1:
		return str(quantity) + " " + word + "S"
	return str(quantity) + " " + word

# Assemble text for the display.
func format_text():
	match displaying:
		DISPLAY_LANE_HUNTED:
			set_upper_text("MARVELOUS!")
			set_lower_text("")
		DISPLAY_X2:
			set_upper_text("X2 BONUS")
			set_lower_text("")
		DISPLAY_X4:
			set_upper_text("X4 BONUS")
			set_lower_text("")
		DISPLAY_X8:
			set_upper_text("X8 BONUS")
			set_lower_text("")
		DISPLAY_LOCKED:
			set_upper_text("BALL LOCKED")
			set_lower_text("")
		DISPLAY_BALL_SAVED:
			set_upper_text("REBORN!")
			set_lower_text("")
		DISPLAY_LANE_REWARD:
			set_upper_text("INSPIRATION")
			set_lower_text("")
		DISPLAY_TITLE:
			set_upper_text("VIKING PINBALL")
			set_lower_text("BLOOD UPON THE SNOW")
		DISPLAY_TARGET_HUNT:
			set_upper_text("FULL POWER")
			set_lower_text("")
		DISPLAY_LANE_HUNT:
			set_upper_text("MOMENT OF")
			set_lower_text("MADNESS")
		DISPLAY_WIZARD:
			set_upper_text("BERSERK!")
			set_lower_text("")
		DISPLAY_GAME_OVER:
			set_upper_text("GAME OVER")
			set_lower_text("")
		DISPLAY_EXTRA_BALL:
			set_upper_text("EXTRA BALL")
			set_lower_text("")
		DISPLAY_BALL_LOST:
			set_upper_text("BALL LOST")
			set_lower_text("")
		DISPLAY_MULTIBALL:
			set_upper_text("MULTIBALL")
			set_lower_text("ACTIVATED")
		DISPLAY_TARGET_BANK_REWARD:
			set_upper_text("VIKING HEAD!")
			set_lower_text("")
		DISPLAY_LOOP:
			set_upper_text("LOOP!")
			set_lower_text("")
		DISPLAY_JACKPOT:
			set_upper_text("GLORIOUS")
			set_lower_text("")
		DISPLAY_WIZARD_JACKPOT:
			set_upper_text("FULL POWER")
			set_lower_text("")
		DISPLAY_TARGET_HUNT_REWARD:
			set_upper_text("BREAKTHROUGH")
			set_lower_text("")
		DISPLAY_BUMPER_REWARD:
			set_upper_text("BRAINSTORM")
			set_lower_text("COMPLETED")
		DISPLAY_LANE_HUNT_REWARD:
			set_upper_text("SKILL SHOT")
			set_lower_text("")
		DISPLAY_SKILL_SHOT:
			set_upper_text("SKILL SHOT")
			set_lower_text("")
		DISPLAY_SCORE:
			# Show current score and which player’s go it is				
			set_upper_text(str(parameters["score"]))
			if parameters["ball"] == 1:
				set_lower_text("PLAYER 1")
			elif parameters["ball"] == 2:
				set_lower_text("PLAYER 2")
			else:
				set_lower_text("GAME")
		DISPLAY_FINAL_SCORE:
			# Show both players’ scores and the result
			set_upper_text("P1:" + str(parameters["player1_score"]) + " P2:" + str(parameters["player2_score"]))
			set_lower_text(parameters["final"]) 
		DISPLAY_FINAL_RESTART:
			set_upper_text("PRESS SPACE TO")
			set_lower_text("RESTART")
		DISPLAY_HELP_KEY:
			set_upper_text("PRESS I FOR")
			set_lower_text("INSTRUCTIONS")
		DISPLAY_START_KEY:
			set_upper_text("PRESS SPACE")
			set_lower_text("TO BEGIN")
		DISPLAY_LANE_HUNT_RULES:
			set_upper_text("SHOOT ALL")
			set_lower_text("FLASHING LANES")
		DISPLAY_TARGET_HUNT_RULES:
			set_upper_text("CLEAR BOTH")
			set_lower_text("VIKING HEADS")
		DISPLAY_BUMPER_PROGRESS:
			set_upper_text(pluralize(parameters["progress"], "BUMPER") + " FOR")
			set_lower_text("BREAKTHROUGH")
		DISPLAY_LANE_HUNT_EXPIRED:
			set_upper_text("OUT OF")
			set_lower_text("TIME")
		DISPLAY_TARGET_HUNT_EXPIRED:
			set_upper_text("OUT OF")
			set_lower_text("TIME")
		DISPLAY_HIGH_SCORE:
			set_upper_text("HIGH SCORE")
			set_lower_text(str(parameters["high_score"]))
		DISPLAY_NEW_HIGH_SCORE:
			set_upper_text("NEW HIGH SCORE!")
			set_lower_text(str(parameters["high_score"]))
		DISPLAY_LANE_BONUS:
			set_upper_text(pluralize(parameters["lanes"], "LIT LANE"))
			set_lower_text(str(parameters["lanes_bonus"]) + " POINTS")
		DISPLAY_LOOP_BONUS:
			set_upper_text(pluralize(parameters["loops"], "LOOP"))
			set_lower_text(str(parameters["loops_bonus"]) + " POINTS")
		DISPLAY_TARGET_BONUS:
			set_upper_text(pluralize(parameters["banks"], "VIKING HEAD"))
			set_lower_text(str(parameters["banks_bonus"]) + " POINTS")
		DISPLAY_TOTAL_BONUS:
			if parameters["multiplier"] == 1:
				set_upper_text("TOTAL BONUS")
			else:
				set_upper_text("TOTAL BONUS X" + str(parameters["multiplier"]))
			set_lower_text(str(parameters["reward"]))
		DISPLAY_WIZARD_READY:
			set_upper_text("SHOOT FLASHING")
			set_lower_text("LANE FOR BERSERK")

# Internal common display logic. Don't call this from outside this script.
func show_something(display_number, and_keep = false):
	displaying = display_number
	# All displays now use text mode
	mode = MODE_TEXT
	format_text()
	
	if sequence:
		# If we're showing a sequence, set a timer to move to the next display.
		$DMDTimer.set_one_shot(false)
		$DMDTimer.start(DISPLAY_TIME[display_number])
	elif and_keep:
		# If we're supposed to keep this display on-screen, turn off the timer.
		$DMDTimer.stop()
	else:
		# If we're not supposed to keep this on-screen, set a timer.
		$DMDTimer.set_one_shot(true)
		$DMDTimer.start(DISPLAY_TIME[display_number])

# Call this function to briefly display a message.
func show_once(display_number):
	if DISPLAY_PRIORITY[display_number] >= DISPLAY_PRIORITY[displaying]:
		sequence = []
		show_something(display_number)

# Call this function to display a message and leave it on the screen.
func show_and_keep(display_number):
	if DISPLAY_PRIORITY[display_number] >= DISPLAY_PRIORITY[displaying]:
		sequence = []
		show_something(display_number, true)

# Call this function to start a sequence, and optionally loop it.
func show_sequence(new_sequence = [], and_repeat = false):
	repeat = and_repeat
	sequence = new_sequence
	sequence_index = 0
	show_something(sequence[0])

# This timer expires after the desired display has been on-screen for a few seconds.
func _on_DMDTimer_timeout():
	if sequence:
		# If we're displaying a sequence, move to the next step.
		sequence_index += 1
		if sequence_index == len(sequence):
			if not repeat:
				# If we're stopping the sequence, display the score.
				show_something(DISPLAY_SCORE, true)
				$DMDTimer.stop()
			else:
				# If we're looping the sequence, start over.
				sequence_index = 0
				show_something(sequence[sequence_index])
		else:
			show_something(sequence[sequence_index])
	else:
		# If we're not displaying a sequence, go back to showing the score.
		show_something(DISPLAY_SCORE, true)
