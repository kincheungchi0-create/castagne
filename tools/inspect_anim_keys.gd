extends SceneTree
var model
var ap
var skel
func _init():
	call_deferred("_start")
func _start():
	var anim = load("res://castagne/assets/fighters/animegirl/anims/ginga_variation_1.anim")
	print("length=", anim.length, " tracks=", anim.get_track_count())
	for i in range(anim.get_track_count()):
		var s = String(anim.track_get_path(i))
		var k0 = anim.track_get_key_value(i, 0) if anim.track_get_key_count(i) > 0 else null
		if s.find("Skeleton:") < 0 or s.ends_with(":mixamorig_Hips") or s.ends_with(":mixamorig_Spine"):
			print(i, " ", s, " k0=", k0)
	model = load("res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn").instance()
	get_root().add_child(model)
	model.scale = Vector3(15,15,15)
	ap = model.get_node("AnimationPlayer")
	for x in _all(model):
		if x is Skeleton:
			skel = x
	print("AABB bind=", _mesh_aabb(model))
	print("hips global bind=", skel.get_bone_global_pose(skel.find_bone("mixamorig_Hips")))
	ap.play("ginga_variation_1", -1, 0.0, false)
	ap.seek(0.0, true)
	call_deferred("_after0")
func _after0():
	print("AABB t0=", _mesh_aabb(model))
	print("hips global t0=", skel.get_bone_global_pose(skel.find_bone("mixamorig_Hips")))
	ap.seek(1.0, true)
	call_deferred("_after1")
func _after1():
	print("AABB t1=", _mesh_aabb(model))
	print("hips global t1=", skel.get_bone_global_pose(skel.find_bone("mixamorig_Hips")))
	print("hips pose t1=", skel.get_bone_pose(skel.find_bone("mixamorig_Hips")))
	quit()
func _mesh_aabb(n):
	var acc = null
	for x in _all(n):
		if x is MeshInstance and x.mesh:
			var xf = x.global_transform
			var a = x.get_aabb()
			var g = AABB(xf.xform(a.position), Vector3())
			g = g.expand(xf.xform(a.position + a.size))
			g = g.expand(xf.xform(Vector3(a.position.x+a.size.x, a.position.y, a.position.z)))
			g = g.expand(xf.xform(Vector3(a.position.x, a.position.y+a.size.y, a.position.z)))
			g = g.expand(xf.xform(Vector3(a.position.x, a.position.y, a.position.z+a.size.z)))
			if acc == null:
				acc = g
			else:
				acc = acc.merge(g)
	return acc
func _all(n):
	var o=[n]
	for c in n.get_children():
		o += _all(c)
	return o
