extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

export var current_n:int = 0

onready var ray = $RayCast

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	DevTools.out('Beam Rot', ray.rotation)
	DevTools.out('Beam Rot Deg', ray.rotation_degrees)
	DevTools.out('Beam', ray.transform.basis)
	shoot()


func stepped_vector(p, step=0.01):
	return [
		stepify(p.x, step), 
		stepify(p.y, step), 
		stepify(p.z, step)
	]
	
	
func shoot(n:int=0):
	"""Cast the ray FORWARD from the nth (0) position. If a hit occurs, the
	hit position is stored for another iteration from n+1 step.
	"""
	
	# move step n 0
	move_ray(0)
	# wait
	# Check if collidiing
		# If true
			# render hit at position
				# stack position transform
				# move ray to transform
				# curremt step is n+1
		
	
func render_ray_step(position:int=0):
	"""The ray is colliding. Render the collision 
	the the current step position, allowing the ray to 
	march onward."""
	# Notice the positions are _relative_ to the parent
	var hit_norm = ray.get_collision_normal()
	var hit_point = ray.get_collision_point()
	DevTools.out('Hit Norm', hit_norm)
	DevTools.out('Hit Point', hit_point)
	
	store_transforms(position, hit_point, hit_norm)
	
	render_hit_point(hit_point)
	render_surface_normal(hit_point, hit_norm)
	
	#reposition_ray(hit_point, hit_norm)
	
func reposition_ray(hit_point, hit_norm):
	ray.global_transform.origin = hit_point 
	ray.global_transform = align_with_y(ray.global_transform, hit_norm)
	
func render_hit_point(hit_point):
	$Spot.global_transform.origin = hit_point
	$Spot.visible = true 


func render_surface_normal(hit_point, hit_norm):
	$SurfaceNormal.visible = true 
	$SurfaceNormal.global_transform.origin = hit_point
	$SurfaceNormal.global_transform = align_with_y($SurfaceNormal.global_transform, hit_norm)
	
	
var hit_stack = {}


func align_with_y(xform, new_y):
	"""Perform an _alignment_ of Vector3 position with target surface 
	Using one transform to another Vector3 normal 
	
		var normal = $RayCast.get_collision_normal()
		$Item.global_transform = align_with_y($Item.global_transform, normal)
	
	The 'normal' presents the _direction_ in 3D space to rotate the transform, 
	Returns the original transform with a transformed basis.
	
	The same may be done with the builtin tools upon the -Z axis:
		
		var ind_norm = $Indicator.global_transform.origin - normal
		var y_normal = $Indicator.global_transform.basis.y.normalized()
		$Indicator.look_at(ind_norm, y_normal)
		
	"""
	# Given a transform and a new Y direction vector, 
	# this function returns the transform rotated so that its basis.y 
	# is aligned with the given normal.
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func store_transforms(position, hit_point, hit_norm):
	"""Given the relative position and rotation normal
	store the point as a _hit_ for presentation
	"""
	hit_stack[position] = [hit_point, hit_norm]
	
	
func move_ray(positon_n:int=0):
	# current_n = positon_n
	# Get transform for hit point.
	var tr = get_transforms(positon_n)
	draw_reflect_lines()	
#	ray.transform.origin = tr[0]
#	ray.transform.basis = Basis(tr[1])

func get_transforms(position):
	"""Return the direction normals for the given positon.
	Position 0 is the same as the Ray default position.
	"""
	if position == 0:
		return default_transforms()	

var ticker:float = 0.0


func default_transforms():
	"""Return the default position set for the ray initial position
	"""
	ticker += 0.001
	DevTools.out('Ticker', ticker)
	if ticker > PI*2:
		ticker = 0
	# Default transform relative to the parent.
	# origin = 0,0,0, 
	# basis (rotation) = -180, 0, 0 (pointing down)
	return [Vector3(0,0,0), Vector3(PI,0,0)]
	
	
func draw_reflect_lines():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var hit_point:Vector3 = ray.get_collision_point()
	
	# Multiply the reference ray local position (the hit point)
	# By Y (up relative to the ray), 
	# Then convert the local transform location to a global
	# transform through _this_ - the parent of the ref ray.
#	var newl = ref_ray.transform * Vector3(0,1,0)
	var newl = to_global(ray.transform * Vector3(0,1,0))
#	newl = Basis(hit_point).get_euler() #* hit_norm# * Vector3(0,0,0)
	DevTools.out('Ref ray transform', ray.transform.basis.get_euler())
	DevTools.out('Ref ray vector ', newl)
#	newl = Basis(hit_point).get_rotation_quat()
#	newl.set_axis_angle(Vector3(0,1,0), hit_point.dot(hit_norm))
#	newl = newl.get_euler()
	# Draw two global positioned lines. 
	# 1. from the original location to the hit point
	var idr = global_transform.origin
	DrawLine3D.DrawLine(idr, hit_point, Color(1, 0, 1))
	# 2. From the original location and the _end_ location
	# (the newly translated 
	DrawLine3D.DrawLine(hit_point, newl, Color(0, 1, 1))
	#DrawLine3D.DrawLine(idr, (hit_point ), Color(0, 1, 1))
