extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export onready var ray = $RayCast
export onready var reflect_ray = $ReflectRayCast
export onready var spot = $Spot
onready var surface_norm_ind:Spatial = $SurfaceNormal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func is_colliding():
	return ray.is_colliding()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		show_hit_point()
		show_surface_vector()
		show_reflect_vector()
		

func show_hit_point():
	var hit_point:Vector3 = ray.get_collision_point()
	var hit_norm:Vector3 = ray.get_collision_normal()
	spot.global_transform.origin = hit_point
	

func show_surface_vector():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var hit_point:Vector3 = ray.get_collision_point()
	surface_norm_ind.global_transform.origin = hit_point
	surface_norm_ind.global_transform = align_with_y(surface_norm_ind.global_transform, hit_norm)
#	surface_norm_ind.transform.basis = hit_norm

func show_reflect_vector():
	
	var hit_point:Vector3 = ray.get_collision_point()
	var reflect:Basis = get_reflect_basis()
	
	reflect_ray.global_transform.origin = hit_point 
	reflect_ray.global_transform.basis = reflect

func reflect_global_transform():
	return reflect_ray.global_transform
	
	
func get_reflect_basis():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var incident_ray_basis:Basis = global_transform.basis
	var reflect:Basis = incident_ray_basis.rotated(hit_norm, PI)
	return reflect 
	
	
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
