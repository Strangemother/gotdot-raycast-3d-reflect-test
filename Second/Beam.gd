extends Spatial

onready var DevTools = get_node('/root/World/DevTools')

onready var ref_ray:Spatial = $ReflectRayCast
onready var ray:Spatial = $RayCast
onready var spot:Spatial = $Spot
onready var norm_ind:Spatial = $Normal
onready var surface_norm_ind:Spatial = $SurfaceNormal

export var show_hit:bool = false
export var show_normal:bool = false

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
	if show_hit:
		spot.visible = true
		
	if show_normal:
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
	surface_norm_ind.global_transform.origin = hit_point
	surface_norm_ind.global_transform = align_with_y(surface_norm_ind.global_transform, hit_norm)
#	surface_norm_ind.global_transform.basis = hit_norm


func show_reflect():
	var hit_norm:Vector3 = ray.get_collision_normal()
	var hit_point:Vector3 = ray.get_collision_point()	
	
	var indicent_ray_basis:Basis = global_transform.basis
	
	ref_ray.global_transform.origin = hit_point 
	ref_ray.global_transform.basis = indicent_ray_basis.rotated(hit_norm, PI)
	
	
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

