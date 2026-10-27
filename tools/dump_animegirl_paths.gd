extends SceneTree
func _init():
	call_deferred("_go")
func _go():
	var root = load("res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn").instance()
	print("ROOT ", root.name, " class=", root.get_class())
	_walk(root, "", 0)
	var ap = root.get_node("AnimationPlayer")
	print("AP root_node=", ap.root_node)
	var anim = ap.get_animation("ginga_variation_1")
	print("tracks=", anim.get_track_count())
	for i in range(min(10, anim.get_track_count())):
		print(" track", i, " path=", String(anim.track_get_path(i)), " type=", anim.track_get_type(i))
	# find Skeleton nodes
	var skels = []
	_find_class(root, "Skeleton", skels)
	for s in skels:
		print("SKEL ", root.get_path_to(s), " bones=", s.get_bone_count())
		if s.get_bone_count() > 0:
			print(" bone0=", s.get_bone_name(0), " bone1=", s.get_bone_name(1))
	root.free()
	quit()
func _walk(n, prefix, depth):
	if depth > 6:
		return
	print(prefix, n.name, " [", n.get_class(), "]")
	for c in n.get_children():
		if c.get_class() == "MeshInstance" and depth > 3:
			continue
		_walk(c, prefix + "  ", depth + 1)
func _find_class(n, cls, out):
	if n.get_class() == cls:
		out.append(n)
	for c in n.get_children():
		_find_class(c, cls, out)
