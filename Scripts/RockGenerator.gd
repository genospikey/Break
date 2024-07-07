extends Node2D
class_name RockGenerator

#when rock breaks
signal rock_break(type)
signal rock_left(type)

var Rock = preload("res://Scenes/Rock.tscn")
var viewport = null

enum {ROCK_NORMAL, ROCK_MULTI, ROCK_SPLIT, ROCK_BAD}

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_viewport_rect().size
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_rock():
	#generate rocks
	var rock = Rock.instantiate()
	
	#set rock type
	rock.set_type()
	
	#spawn offscreen
	rock.position = _get_init_location()
	rock.linear_velocity = _get_init_velocity(rock)
	rock.angular_velocity = randf_range(0,3)
	
	var scale = randf_range(0.9, 1.5)
	rock.set_rock_scale(scale)
	rock.dead.connect(_handle_destroy_rock)
	rock.left.connect(_handle_rock_left)
	add_child(rock)
	

func _get_init_location():
	#currently will pick a random location on the outside of the viewing area
	#rocks leave when they leave the play area
	var x = 0
	var y = 0
	var margin = 50
	match randi_range(0,3):
		0:
			x = randi_range(-margin,viewport.x+margin)
			y = -margin
		1:
			x = randi_range(-margin,viewport.x+margin)
			y = viewport.y + margin
		2:
			x = 0
			y = randi_range(-margin ,viewport.y + margin)
		3:
			x = viewport.x + margin
			y = randi_range(-margin ,viewport.y + margin)
		
	return Vector2(x,y)

func _get_init_velocity(rock):
	
	var speed = 450
	var dir = Vector2(viewport.x/2 - rock.position.x, viewport.y/2 - rock.position.y).normalized()
	var antigrav = Vector2(0,-rock.gravity_scale*400)
	return speed * dir + antigrav

func _handle_destroy_rock(rock):
	#update score
	rock_break.emit(rock)
	
	#spawn two rocks, maybe another multi and launch
	if rock.type == ROCK_SPLIT:
		var multi_rock = Rock.instantiate()
		
		multi_rock.position = rock.position
		
		#set rock type
		multi_rock.set_type(ROCK_NORMAL)
		multi_rock.dead.connect(_handle_destroy_rock)
		multi_rock.left.connect(_handle_rock_left)
		
		multi_rock.set_rock_scale(randf_range(.65,.85))
		
		#launch it
		var launch = Vector2.UP.rotated(randf_range(-.5,-.15)) * 500
		multi_rock.linear_velocity = launch + rock.linear_velocity * .5
		multi_rock.angular_velocity = randf_range(0,3)
		
		add_child(multi_rock)
		
		multi_rock = Rock.instantiate()
		
		multi_rock.position = rock.position
		multi_rock.position.x += 5
		
		#set rock type
		multi_rock.set_type(ROCK_NORMAL)
		multi_rock.dead.connect(_handle_destroy_rock)
		multi_rock.left.connect(_handle_rock_left)
		
		multi_rock.set_rock_scale(randf_range(.65,.85))
		
		#launch it
		launch = Vector2.UP.rotated(randf_range(.15,.5)) * 500
		multi_rock.linear_velocity = launch + rock.linear_velocity * .5
		multi_rock.angular_velocity = randf_range(0,3)
		
		add_child(multi_rock)
	
	#destroy
	rock.destroy()

func _handle_rock_left(rock):
	#update score
	rock_left.emit(rock)
	
	#destroy
	rock.destroy()
