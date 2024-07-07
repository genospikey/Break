extends CPUParticles2D
class_name RockSpray

# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	await(get_tree().create_timer(0.5).timeout)
	queue_free()
