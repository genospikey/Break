extends RigidBody2D



signal dead
signal left

var badRocKTexture = preload("res://Assets/Textures/badrock.png")
var RockSpray = preload("res://Scenes/RockSpray.tscn")
var BadSpray = preload("res://Scenes/BadSpray.tscn")

var viewport_size = null
var tap = false
var health = 1
var on_screen = 0
var scale_number = 1
var type = null

var hit_delay = false

enum {ROCK_NORMAL, ROCK_MULTI, ROCK_SPLIT, ROCK_BAD}

# Called when the node enters the scene tree for the first time.
func _ready():

	viewport_size = get_viewport_rect().size
	
	var os_name = OS.get_name()
	if os_name == 'iOS' || os_name == 'Android':
		tap = true

	pass # Replace with function body.

func set_type(spawn_type=null):
	if spawn_type == null:
		spawn_type = randi_range(0,3)
	
	match spawn_type:
		ROCK_NORMAL:
			type = ROCK_NORMAL
		ROCK_MULTI:
			#multihit
			type = ROCK_MULTI
			modulate = Color(0,0,1)
			health = 2
		ROCK_SPLIT:
			#split
			type = ROCK_SPLIT
			modulate = Color(0,1,0)
		ROCK_BAD:
			#fire
			type = ROCK_BAD
			modulate = Color(1,0,0)
			$Sprite2D.texture = badRocKTexture
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Detect selection and damage rock
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed == true:
		_damage(1, event.position)
	#if event is InputEventScreenTouch and event.pressed == true:
		#_damage(1, event.position)

func _damage(amount, location=Vector2(0,0)):
	#damage
	health = health - amount
	
	if health > 0:
		modulate = modulate.lightened(0.3)
		pass
	
	#emit tiny rocks
	var emitter
	
	if type == ROCK_BAD:
		emitter = BadSpray.instantiate()
	else:
		emitter = RockSpray.instantiate()
		
		#more particles of exploding
		if health <= 0:
			emitter.amount = 12
	
	emitter.position = position
	emitter.color = modulate
	emitter.scale = Vector2(scale_number,scale_number)
	
	#attach to scene
	get_parent().add_child(emitter)
	
	#dead - deletion done by rock generator
	if health <= 0:
		dead.emit(self)
	else:
		#get mouse position and direction to center
		var dir = (location - global_position).normalized()
		var force = 100
		var upforce = 300
		apply_impulse(dir * force + Vector2.UP * upforce)


func destroy():
	queue_free()

func _on_screen_exited():
	left.emit(self)
	
func set_rock_scale(input_scale):
	scale_number = input_scale
	$Sprite2D.scale *= input_scale
	$CollisionShape2D.scale *= input_scale
	$VisibleOnScreenNotifier2D.scale *= input_scale
