extends Node2D

var lifetime = 1
var time = 0
var speed = -20

@onready var label = $Label

func update_text(damage):
	if damage > 0:
		label.text = '+' + str(damage)
	else:
		label.text = str(damage)
		modulate = Color(1,0,0,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = time + delta
	
	if time > lifetime:
		queue_free()
	
	position.y += delta * speed
	if modulate.a >= 0:
		modulate.a -= delta
		
	if modulate.a < 0:
		modulate.a = 0
