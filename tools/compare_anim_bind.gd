extends SceneTree
func _init():
	call_deferred("_go")
func _go():
	var root = load("res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn").instance()
	get_root().add_child(root)
	var skel
	for n in _all(root):
		if n is Skeleton:
			skel = n
			break
	var hips_i = skel.find_bone("mixamorig_Hips")
	print("REST hips=", skel.get_bone_rest(hips_i))
	print("POSE before=", skel.get_bone_pose(hips_i))
	var ap = root.get_node("AnimationPlayer")
	var anim = ap.get_animation("ginga_variation_1")
	# find hips track
	for i in range(anim.get_track_count()):
		var s = String(anim.track_get_path(i))
		if s.ends_with(":mixamorig_Hips") or s.find("mixamorig_Hips") >= 0 and s.find("_end") < 0:
			print("hips track ", i, " path=", s, " type=", anim.track_get_type(i), " keys=", anim.track_get_key_count(i))
			if anim.track_get_key_count(i) > 0:
				print("  key0=", anim.track_get_key_value(i, 0))
				print("  key1=", anim.track_get_key_value(i, min(1, anim.track_get_key_count(i)-1)))
	# Also open source anim glb skeleton rest
	var src = load("res://castagne/assets/fighters/animegirl/models/ginga_variation_1.glb").instance()
	var src_skel
	for n in _all(src):
		if n is Skeleton:
			src_skel = n
			break
	var sh = src_skel.find_bone("mixamorig_Hips")
	print("SRC REST hips=", src_skel.get_bone_rest(sh))
	print("SRC bone count=", src_skel.get_bone_count(), " CHAR bone count=", skel.get_bone_count())
	# compare bone names order
	var mismatch = 0
	for b in range(min(skel.get_bone_count(), src_skel.get_bone_count())):
		if skel.get_bone_name(b) != src_skel.get_bone_name(b):
			mismatch += 1
			if mismatch <= 5:
				print("name mismatch ", b, " ", skel.get_bone_name(b), " vs ", src_skel.get_bone_name(b))
	print("name mismatches=", mismatch)
	# compare rests for hips/spine
	for bname in ["mixamorig_Hips", "mixamorig_Spine", "mixamorig_LeftUpLeg"]:
		var a = skel.find_bone(bname)
		var b = src_skel.find_bone(bname)
		print(bname, " char_rest=", skel.get_bone_rest(a).origin, " src_rest=", src_skel.get_bone_rest(b).origin)
	src.free()
	quit()
func _all(n):
	var o = [n]
	for c in n.get_children():
		o += _all(c)
	return o
