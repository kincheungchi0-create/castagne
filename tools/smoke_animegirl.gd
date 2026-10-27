extends SceneTree
func _init():
	call_deferred("_go")
func _go():
	var root = load("res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn").instance()
	get_root().add_child(root)
	var meshes = []
	_find(root, "MeshInstance", meshes)
	print("meshes=", meshes.size())
	var ap = root.get_node("AnimationPlayer")
	print("root_node=", ap.root_node, " has ginga=", ap.has_animation("ginga_variation_1"))
	ap.play("ginga_variation_1")
	ap.seek(0.5, true)
	var skel = null
	var skels = []
	_find(root, "Skeleton", skels)
	skel = skels[0]
	var hips = skel.find_bone("mixamorig_Hips")
	print("hips bone=", hips, " pose=", skel.get_bone_pose(hips))
	print("aabb sample mesh=", meshes[0].get_aabb() if meshes.size() else null)
	print("global mesh=", meshes[0].global_transform.origin if meshes.size() else null)
	quit()
func _find(n, cls, out):
	if n.get_class() == cls:
		out.append(n)
	for c in n.get_children():
		_find(c, cls, out)
