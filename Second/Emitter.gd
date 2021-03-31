extends Spatial

onready var DevTools = get_node('/root/World/DevTools')

onready var ref_ray:Spatial = $ReflectRayCast
onready var ray:Spatial = $RayCast
onready var spot:Spatial = $Spot
onready var norm_ind:Spatial = $Normal
onready var surface_norm_ind:Spatial = $SurfaceNormal


func _ready():
	pass # Replace with function body.


func _process(delta):
	if ray.is_colliding():
		render_collide()
	else:
		hide_collider()

func hide_collider():
	ref_ray.visible = false
	spot.visible = false
	surface_norm_ind.visible = false
	norm_ind.visible = false

func render_collide():
	ref_ray.visible = true
	spot.visible = true
	surface_norm_ind.visible = true
	norm_ind.visible = true
	
	ref_ray.rotation_degrees = Vector3(0,0,0)
	
	show_hit_point()
	show_hit_normal()
	show_surface_vector()
	show_reflect()
	
	
	
func show_hit_normal():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var n = "Ray Hit Normal %s" % self.name
	#DevTools.out(n, stepped_vector(hit_norm))
	var hit_point:Vector3 = ray.get_collision_point()

	norm_ind.global_transform.origin = hit_point# + (hit_norm*.5)
	norm_ind.global_transform.basis = hit_norm


func show_surface_vector():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var hit_point:Vector3 = ray.get_collision_point()
	surface_norm_ind.global_transform.origin = hit_point# + (hit_norm*.5)
#	surface_norm_ind.look_at(transform.origin - Vector3(0,-1,0), Vector3.UP)
	
#	var normal = $RayCast.get_collision_normal()
	surface_norm_ind.global_transform = align_with_y(surface_norm_ind.global_transform, hit_norm)


func show_reflect():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var hit_point:Vector3 = ray.get_collision_point()	
	ref_ray.global_transform.origin = hit_point# + (hit_norm*.5)
	var rot = ref_ray.global_transform.basis.get_euler()
	
	if hit_norm.x == -1:
		return y_plane_reflect()
	else:
		return z_plane_reflect()


func y_plane_reflect():
#	ref_ray.global_transform.basis = rot 
	var rot = ref_ray.global_transform.basis.get_euler()
	var n = "Y %s" % self.name
	var hit_norm:Vector3 = ray.get_collision_normal()
	DevTools.out(n, rot)
#	norm_ind.rotation = rot
#	ref_ray.global_transform.basis = ref_ray.global_transform.basis.inverse()

	## East Wall
	var ref:Basis = global_transform.basis#.inverse()
	ref.y *= -1
	ref.z *= -1
	ref_ray.global_transform.basis = ref.get_euler().reflect(hit_norm)
#	y_reflect()
	
	
func z_plane_reflect():
	var hit_norm:Vector3 = ray.get_collision_normal()
	
#	ref_ray.global_transform.basis = global_transform.basis.get_euler().reflect(hit_norm)	
#	ref_ray.global_transform.basis = global_transform.basis.inverse()
	if hit_norm.x == 1:
		return neg_x_z_plane_reflect()		
	
	#var n = "Z %s" % self.name
	#DevTools.out(n, hit_norm)
	
	if hit_norm.z == -1:
		return neg_z_z_plane_reflect()		
	
	# Shooting down	
	var input_basis:Basis = global_transform.basis
	var surface_transform = surface_norm_ind.global_transform
	var v = input_basis.get_euler()
#	v = surface_transform#.inverse()
	var surf_norm = surface_norm_ind.global_transform.basis.get_euler()
	ref_ray.global_transform.basis = Basis(input_basis).rotated(hit_norm, PI)#.get_euler().reflect(hit_norm)
#	ref_ray.global_transform.basis = ref_ray.global_transform.basis.rotated(hit_norm, PI)
	## copy the inbound vector (the ray gun) to the output.
#	ref_ray.global_transform.basis = input_basis
	
	## copy the surface rotation to the output ray
#	ref_ray.global_transform = surface_transform
	var n = "Z Basis %s" % self.name
	DevTools.out(n, stepped_vector(ref_ray.rotation_degrees))
		
		
func neg_z_z_plane_reflect():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var ref:Basis = global_transform.basis
#	ref.x *= -1
	ref.y *= -1
	ref_ray.global_transform.basis = -ref.get_euler()
	var n = "Z Z %s" % self.name
	DevTools.out(n, ref.get_euler())
	
	
func neg_x_z_plane_reflect():
	# From right to left (gun facing west)
	var n = "X Z %s" % self.name
	var hit_norm:Vector3 = ray.get_collision_normal()
	DevTools.out(n, hit_norm)	
	
	var ref:Basis = global_transform.basis.get_euler().reflect(hit_norm)
	ref.y *= -1
	
	ref_ray.global_transform.basis = ref

	
func show_hit_point():
	var hit_point:Vector3 = ray.get_collision_point()
	spot.global_transform.origin = hit_point


func stepped_vector(p, step=0.01):
	return [
		stepify(p.x, step), 
		stepify(p.y, step), 
		stepify(p.z, step)
	]

#mat3x3 rotationAlign( const vec3 & d, const vec3 & z )
#
#    const vec3  v = cross( z, d );
#    const float c = dot( z, d );
#    const float k = 1.0f/(1.0f+c);
#
#    return mat3x3( v.x*v.x*k + c,     v.y*v.x*k - v.z,    v.z*v.x*k + v.y,
#                   v.x*v.y*k + v.z,   v.y*v.y*k + c,      v.z*v.y*k - v.x,
#                   v.x*v.z*K - v.y,   v.y*v.z*k + v.x,    v.z*v.z*k + c    );
#
		
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

func rotationAlign(d:Vector3, z:Vector3):
	
	var v:Vector3 = z.cross(d)
	var c:float = z.dot(d )
	var k:float = 1.0 / (1.0 + c)

	return Basis( Vector3(v.x*v.x*k + c,     v.y*v.x*k - v.z,    v.z*v.x*k + v.y),
				   Vector3(v.x*v.y*k + v.z,   v.y*v.y*k + c,      v.z*v.y*k - v.x),
				   Vector3(v.x*v.z*k - v.y,   v.y*v.z*k + v.x,    v.z*v.z*k + c    ))

