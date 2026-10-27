extends SceneTree
# Point AnimationPlayer.root_node at the imported RootNode so Object_4/Skeleton:* tracks resolve.

const DEST = "res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn"

func _init():
	call_deferred("_go")

func _go():
	var ps = load(DEST)
	var root = ps.instance()
	var ap = root.get_node("AnimationPlayer")
	var skel = _find_skel(root)
	if skel == null:
		printerr("no skeleton")
		quit(1)
		return
	# RootNode is parent of Object_4 which parents Skeleton
	var object4 = skel.get_parent() # Object_4
	var root_node = object4.get_parent() # RootNode
	print("Skeleton path from AnimeGirl: ", root.get_path_to(skel))
	print("RootNode path from AnimeGirl: ", root.get_path_to(root_node))
	print("RootNode path from AP: ", ap.get_path_to(root_node))

	# root_node is relative to AnimationPlayer
	ap.root_node = ap.get_path_to(root_node)
	print("set AP.root_node=", ap.root_node)

	# Verify first tracks resolve
	var anim = ap.get_animation("ginga_variation_1")
	var base = ap.get_node(ap.root_node)
	var ok = 0
	var bad = 0
	for i in range(anim.get_track_count()):
		var p = anim.track_get_path(i)
		# NodePath may be "Object_4/Skeleton:mixamorig_Hips"
		var node_path = p
		# has_node doesn't work with property subnames - strip after :
		var s = String(p)
		var np = s
		if s.find(":") >= 0:
			np = s.split(":")[0]
		if base.has_node(np):
			ok += 1
		else:
			bad += 1
			if bad <= 5:
				print("BAD ", s)
	print("resolve ok=", ok, " bad=", bad)

	# Also check bone names exist on skeleton for a few
	var bone_ok = 0
	var bone_bad = 0
	for i in range(anim.get_track_count()):
		var s = String(anim.track_get_path(i))
		if s.find(":") < 0:
			continue
		var bone = s.split(":")[1]
		var bi = skel.find_bone(bone)
		if bi >= 0:
			bone_ok += 1
		else:
			bone_bad += 1
			if bone_bad <= 5:
				print("MISSING BONE ", bone)
	print("bones ok=", bone_ok, " bad=", bone_bad)

	_set_owner_recursive(root, root)
	var out = PackedScene.new()
	var err = out.pack(root)
	if err != OK:
		printerr("pack ", err)
		quit(1)
		return
	err = ResourceSaver.save(DEST, out)
	print("SAVE err=", err, " root_node=", ap.root_node)
	root.free()
	quit(0 if err == OK and bad == 0 else 2)

func _find_skel(n):
	if n is Skeleton:
		return n
	for c in n.get_children():
		var f = _find_skel(c)
		if f:
			return f
	return null

func _set_owner_recursive(n, own):
	for c in n.get_children():
		c.owner = own
		_set_owner_recursive(c, own)
