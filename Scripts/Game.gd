extends Node2D

enum {ROCK_NORMAL, ROCK_MULTI, ROCK_SPLIT, ROCK_BAD}
enum {MAIN_MENU, PLAYING, PAUSED, END, TRANSITION}

var score = 0
var high_score = 0
var state = MAIN_MENU
var timer = null
var time_left = 0
var game_time = 30

@onready var rock_generator = $RockGenerator
@onready var ui = $UI

var DamageText = preload("res://Scenes/damage_text.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	print(rock_generator)
	rock_generator.rock_break.connect(_handleScoreUpdate)
	rock_generator.rock_left.connect(_handleRockLeft)
	
	#ticks every second
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_handleTimerUpdate)
	
	#ui setup
	ui.start_game.connect(start_game)
	ui.pause_game.connect(pause_game)
	ui.menu.connect(go_to_menu)
	ui.change.connect(transition_change_state)
	ui.game_menu()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _handleScoreUpdate(rock):
	
	var dt = DamageText.instantiate()
	dt.position = rock.position
	add_child(dt)
	
	match rock.type:
		ROCK_NORMAL:
			score += 1
			dt.update_text(1)
		ROCK_SPLIT:
			score += 1
			dt.update_text(1)
		ROCK_BAD:
			score -= 5
			dt.update_text(-5)
		ROCK_MULTI:
			score += 5
			dt.update_text(5)
	
	ui.update_score(score)
	pass

func _handleRockLeft(rock):
	pass

func _checkForEnd():
	if time_left <= 0 && get_tree().get_nodes_in_group("rock").size()==0:
		end_game()
	
func _handleTimerUpdate():
	time_left -= 1
	
	if time_left < 0: 
		time_left = 0
	
	ui.update_timer(time_left)
	
	if time_left > 1:
		rock_generator.spawn_rock()
	
	_checkForEnd()

func start_game():
	transition(PLAYING)
	
	#show ui
	time_left = game_time
	score = 0
	ui.update_score(score)
	ui.update_timer(time_left)
	timer.start()
	state = PLAYING

func pause_game():
	if get_tree().paused:
		get_tree().paused = false
		ui.game_playing()
		state = PLAYING
	else:
		get_tree().paused = true
		ui.game_paused()
		state = PAUSED

func go_to_menu():
	#stop timer
	timer.stop()
	
	transition(MAIN_MENU)
	

func end_game():
	timer.stop()
	
	if score > high_score:
		high_score = score
	
	#clear out rocks
	for i in rock_generator.get_children():
		i.queue_free()
	
	var end_text = 'Time Elapsed: ' + str(game_time) + '\n'
	end_text += '\n'
	end_text += 'Score: ' + str(score) + '\n'
	end_text += 'High Score: ' + str(high_score)
	ui.update_end(end_text)	
	ui.game_end()

func transition(future_state):
	#set state
	state = TRANSITION
	
	#play animation
	ui.transition(future_state)

func transition_change_state(future_state):
	match future_state:
		PLAYING:
			ui.game_playing()
		MAIN_MENU:
			#clear out rocks
			for i in rock_generator.get_children():
				i.queue_free()
			
			#unpause
			if get_tree().paused:
				get_tree().paused = false

			ui.game_menu()
