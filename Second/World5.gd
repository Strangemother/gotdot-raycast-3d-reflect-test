extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # $AnimationPlayer.play("New Anim")


### Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	DevTools.out('Beam3', $Beam3.rotation_degrees)
##	$Spatial3.rotation.y += delta * .5
#	var sb:Basis = $Spatial/working2/Beam2.transform.basis
#	$Spatial/working2/Beam2.rotate_object_local(Vector3(0,1,0), delta)
