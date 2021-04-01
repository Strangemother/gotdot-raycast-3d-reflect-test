"""Sputter Gun.
"""
extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var _sputter_ticker:int = 0
var ticker = 0

# tick every 1s
export var sputter_rate:int = 1000
export var sputter_value:int = 0

var shots:int = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_sputter_ticker += 1  
	# every 500ms
	
	if _sputter_ticker % sputter_rate == 0:
		_sputter_ticker = 0
		sputter_value += 1
		#DevTools.out('sputter_value', sputter_value)
		gun_step(delta)

var Beam = preload("res://SputterBeam.tscn")

var current_step:int = 0 


func gun_step(delta):
	var fire = true
	var c = 0
	
	var isnew_and_beam = get_ray_at_position(c)
	var _isnew = isnew_and_beam[0]
	var beam = isnew_and_beam[1]
	var location = null

	print('\nFiring')
	var while_ticker = 0
	
	while fire == true: 
		while_ticker += 1
		if beam.is_colliding():
			print('Hit ', c)
#			fire = while_ticker == 2
			# Generate a new ray
			c += 1
			isnew_and_beam = get_ray_at_position(c)
			_isnew = isnew_and_beam[0]
			var next_beam = isnew_and_beam[1]
			copy_reflect(beam, next_beam, c-1)
			beam = next_beam
			print('next beam', beam)
		else:
			print('beam misfire ', c)
			fire = false 
			
		if while_ticker > 10:
			fire = false
			print('Runaway loop')
			break
		
	print('finished firing')


func copy_reflect(hit_beam:Spatial, target_beam:Spatial, index=null):
	"""Given two Beams, translate the "hit" reflection angle to the
	target beam transform.
	"""
	print('Copying reflection ', index)
	target_beam.global_transform = Transform(hit_beam.reflect_global_transform())
	target_beam.translate_object_local(Vector3(0, 1.1, 0))
	# Rotate around Z axis by 180deg
	target_beam.rotate_object_local(Vector3(0, 0, 1).normalized(), PI)
	
	
func old_gun_step(delta):
	shots += 1
	# Get the ray	
	var isnew_and_beam = get_ray_at_position(current_step)
	var isnew = isnew_and_beam[0]
	var beam = isnew_and_beam[1]
	
	if isnew:
		# A Newly plotted ray. Let's ignore.
		return 
	
	var s = "%s %s %s" % [shots, beam, beam.is_colliding()]
	DevTools.out('Pew!', s)
	
	if beam.is_colliding() == false:
		print('Reset beam from ', current_step)	
		current_step = 0
		return 
		
	print('Move beam ', current_step)
	var isnew_and_beam_2 = get_ray_at_position(current_step)
	var beam2:Spatial = isnew_and_beam[1]
	
	DevTools.out('gun_step last hit A', beam2.global_transform.basis.get_euler())
	beam2.global_transform = Transform(beam.reflect_global_transform())
	beam2.rotate_object_local(Vector3(1, 1, 0), PI)
	DevTools.out('gun_step last hit B', beam2.global_transform.basis.get_euler())
	
	current_step += 1
	if current_step > 3:
		print('Reset Dev steps')
		current_step = 0
	#ray.transform.origin += Vector3(0,0,.1)
#	ray.transform.origin = Vector3(0,0,.5)
	
var rays = {}

func get_ray_at_position(position):
	var isnew:bool = false
	var _ray = rays.get(position, null)
	if _ray == null:
		print('Generate new ray: ', position)
		_ray = new_ray()
		rays[position] = _ray
		isnew = true 
		
	return [isnew, _ray]
	
	
func new_ray():
	var beam = Beam.instance()
	add_child(beam)
	return beam 
	
