extends Node2D
class_name BackgroundGenerator

@onready var base_color = $BaseColorSprite
@onready var sprite_base = $SpriteBase

#a 16x16 square - make it 1x1?
var white_texture = preload("res://Assets/Textures/white_square.png")
var moon_texture = preload("res://Assets/Textures/moon.png")

var preset = SPACE_CANYON
enum {CITIES, SPACE_CANYON}

var preset_list = {
	CITIES: {
		"start" : cities_sky_start,
		"process" : null,
		"end" : cities_sky_end
	},
	SPACE_CANYON: {
		"start": space_canyon_start,
		"process" : null,
		"end" : space_canyon_end
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	if preset_list[preset].start:
		preset_list[preset].start.call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if preset_list[preset].process:
		preset_list[preset].process.call()

func change(new_preset):
	if preset_list[preset].end:
		preset_list[preset].end.call()
	if preset_list[new_preset].start:
		preset_list[new_preset].start.call()

func cities_sky_start():
	#set preset variable
	preset = CITIES
	
	#create a bunc of sprites
	for i in range(12):
		var sprite = Sprite2D.new()
		sprite.texture = white_texture
		var size_x = randi_range(50, 100)
		var size_y = randi_range(50, 200)
		sprite.scale = Vector2(size_x/16,size_y/16)
		sprite.centered = false
		
		var gray_num = .05 + .01 * i
		sprite.modulate = Color(gray_num,gray_num,gray_num)
		
		sprite.position.x = randi_range(-25,base_color.scale.x*16-sprite.scale.x*16+25)
		sprite.position.y = base_color.scale.y*16 - sprite.scale.y*16
		
		#scale and move - 
		sprite_base.add_child(sprite)

func cities_sky_end():
	for i in sprite_base.get_children():
		i.queue_free()

func space_canyon_start():
	#set preset variable
	preset = SPACE_CANYON
	
	base_color.modulate = Color(.03,.03,.1)
	
	#add moon
	var moon = Sprite2D.new()
	moon.texture = moon_texture
	moon.centered = true
	moon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	moon.position.x = 125
	moon.position.y = 125
	
	moon.scale = Vector2(2,2)
	
	moon.modulate = Color(.1,.2,.4)
	
	sprite_base.add_child(moon)
	
	#create a bunc of sprites
	for i in range(3):
		var base_y = 0
		var base_x = randi_range(0,base_color.scale.x*.75)*16
		if i == 0:
			base_x = 0
		var prev_size_y = randi_range(50, 200)
		var rising = true
		
		for j in range(randi_range(20,50)):
			var sprite = Sprite2D.new()
			sprite.texture = white_texture
			var size_x = 8
			
			var y_variance = 0
			if rising:
				y_variance = randi_range(0,20) * 5
				
				if (j > 5 and randf_range(0,1) > .65) or prev_size_y == 500:
					rising = false
			else:
				y_variance = - randi_range(0,20) * 5
				print('fudge')
			
			var size_y = min(prev_size_y + y_variance,500)
			prev_size_y = size_y
			
			sprite.scale = Vector2(size_x/16.0,size_y/16.0)
			sprite.centered = false
			
			var gray_num = .03 * i
			sprite.modulate = Color(.05+gray_num,.1+gray_num,gray_num+.3)
			
			sprite.position.x = base_x + j * 16
			sprite.position.y = base_color.scale.y*16 - sprite.scale.y*16 - base_y
			
			#scale and move - 
			sprite_base.add_child(sprite)

func space_canyon_end():
	for i in sprite_base.get_children():
		i.queue_free()
