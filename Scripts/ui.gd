extends CanvasLayer
class_name UI

signal start_game
signal pause_game
signal menu
signal change

@onready var score_label = $GameControl/ScoreLabel
@onready var timer_label = $GameControl/TimerLabel
@onready var end_label = $EndMenu/EndScoreLabel
@onready var main_menu = $MainMenu
@onready var game_ui = $GameControl
@onready var pause_menu = $PauseMenu
@onready var end_menu = $EndMenu
@onready var anim_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer

var future_state = null

func update_score(score):
	score_label.text = 'Score: ' + str(score)

func update_timer(time):
	timer_label.text = str(time)

func update_end(text):
	end_label.text = str(text)

func _on_quit_button_pressed():
	audio_player.play()
	get_tree().quit()

func _on_play_button_pressed():
	audio_player.play()
	start_game.emit()

func game_playing():
	main_menu.visible = false
	game_ui.visible = true
	pause_menu.visible = false
	end_menu.visible = false	

func game_paused():
	main_menu.visible = false
	game_ui.visible = false
	pause_menu.visible = true
	end_menu.visible = false
	
func game_menu():
	main_menu.visible = true
	game_ui.visible = false
	pause_menu.visible = false
	end_menu.visible = false

func game_end():
	main_menu.visible = false
	game_ui.visible = false
	pause_menu.visible = false
	end_menu.visible = true

func _on_pause_button_pressed():
	audio_player.play()
	pause_game.emit()

func _on_menu_button_pressed():
	audio_player.play()
	menu.emit()

func transition(input):
	future_state = input
	anim_player.play("sweep")

func emit_change():
	change.emit(future_state)
