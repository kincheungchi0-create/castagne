extends SceneTree
# Rebuild AnimeGirlModel as: instance(character.glb) + AnimationPlayer with clips
# copied from anim GLBs, root_node aimed at imported RootNode.

const MODEL_DIR = "res://castagne/assets/fighters/animegirl/models/"
const DEST = "res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn"
const CHAR_GLB = MODEL_DIR + "character.glb"

func _init():
	call_deferred("_go")

func _go():
	var char_ps = load(CHAR_GLB)
	if char_ps == null:
		printerr("FAIL character.glb")
		quit(1)
		return
	var root = char_ps.instance()
	root.name = "AnimeGirl"

	var ap = AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	root.add_child(ap)
	# owner set later

	var skel = _find_skel(root)
	if skel == null:
		printerr("FAIL no skeleton in character.glb")
		quit(1)
		return
	var object4 = skel.get_parent()
	var root_node = object4.get_parent()
	ap.root_node = ap.get_path_to(root_node)
	print("skel=", root.get_path_to(skel))
	print("AP.root_node=", ap.root_node)

	var dir = Directory.new()
	dir.open(MODEL_DIR)
	dir.list_dir_begin(true, true)
	var fname = dir.get_next()
	var added = 0
	while fname != "":
		if fname.ends_with(".glb") and fname != "character.glb":
			var clip = fname.get_basename()
			var ps = load(MODEL_DIR + fname)
			if ps:
				var inst = ps.instance()
				var src_ap = _find_ap(inst)
				if src_ap and not src_ap.get_animation_list().empty():
					var src_name = src_ap.get_animation_list()[0]
					var anim = src_ap.get_animation(src_name).duplicate(true)
					# Retarget track paths if needed: ensure Object_4/Skeleton: prefix
					anim = _normalize_tracks(anim, root_node, skel)
					if ap.has_animation(clip):
						ap.remove_animation(clip)
					ap.add_animation(clip, anim)
					added += 1
				inst.free()
		fname = dir.get_next()
	dir.list_dir_end()
	print("added=", added, " list=", ap.get_animation_list().size())

	# Sanity: resolve tracks for ginga_variation_1
	if ap.has_animation("ginga_variation_1"):
		var anim = ap.get_animation("ginga_variation_1")
		var base = ap.get_node(ap.root_node)
		var ok = 0
		var bad = 0
		for i in range(anim.get_track_count()):
			var s = String(anim.track_get_path(i))
			var np = s.split(":")[0] if s.find(":") >= 0 else s
			if base.has_node(np):
				ok += 1
			else:
				bad += 1
				if bad <= 3:
					print("BAD ", s)
		print("resolve ok=", ok, " bad=", bad)

	_set_owner_recursive(root, root)
	var out = PackedScene.new()
	# Pack with instance edit? For inherited-style, save as scene that still instances glb:
	# Use packed scene from char + edits via PackedScene.GEN_EDIT_STATE — not available outside editor.
	# Instead save flattened but WITHOUT duplicating meshes: keep ExtResource to glb via packing instance.
	# Trick: create container that instances glb
	var holder = Spatial.new()
	holder.name = "AnimeGirl"
	var inst2 = char_ps.instance()
	# Move children? Simpler: save root as-is (flattened from instance) — but then we get meshes again.
	# Prefer: 
	# [node name="AnimeGirl" instance=ExtResource(character.glb)]
	# [node name="AnimationPlayer" parent="."]
	# with animations as subresources — ResourceSaver on AnimationPlayer-only scene won't keep instance.
	#
	# Build manually as text after exporting anims to .tres files.
	root.free()

	# Approach: save AnimationLibrary-like .tres per clip, write thin .tscn by hand
	_export_clips_and_thin_tscn(char_ps, added)
	quit(0)

func _export_clips_and_thin_tscn(char_ps, _added_hint):
	# Re-instance clean
	var root = char_ps.instance()
	root.name = "AnimeGirl"
	var ap = AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	root.add_child(ap)
	var skel = _find_skel(root)
	var root_node = skel.get_parent().get_parent()
	ap.root_node = ap.get_path_to(root_node)

	var anim_dir = "res://castagne/assets/fighters/animegirl/anims/"
	var d = Directory.new()
	if not d.dir_exists(anim_dir):
		d.make_dir_recursive(anim_dir)

	var dir = Directory.new()
	dir.open(MODEL_DIR)
	dir.list_dir_begin(true, true)
	var fname = dir.get_next()
	var clip_names = []
	while fname != "":
		if fname.ends_with(".glb") and fname != "character.glb":
			var clip = fname.get_basename()
			var ps = load(MODEL_DIR + fname)
			var inst = ps.instance()
			var src_ap = _find_ap(inst)
			if src_ap and not src_ap.get_animation_list().empty():
				var anim = src_ap.get_animation(src_ap.get_animation_list()[0]).duplicate(true)
				anim = _normalize_tracks(anim, root_node, skel)
				var anim_path = anim_dir + clip + ".anim"
				var err = ResourceSaver.save(anim_path, anim)
				if err == OK:
					clip_names.append(clip)
					print("saved ", anim_path)
				else:
					printerr("anim save fail ", clip, " ", err)
			inst.free()
		fname = dir.get_next()
	dir.list_dir_end()
	root.free()

	# Write thin tscn
	var lines = []
	lines.append("[gd_scene load_steps=" + str(2 + clip_names.size()) + " format=2]")
	lines.append("")
	lines.append('[ext_resource path="' + CHAR_GLB + '" type="PackedScene" id=1]')
	var id = 2
	for clip in clip_names:
		lines.append('[ext_resource path="' + anim_dir + clip + '.anim" type="Animation" id=' + str(id) + ']')
		id += 1
	lines.append("")
	lines.append('[node name="AnimeGirl" instance=ExtResource( 1 )]')
	lines.append("")
	# root_node path must match instance hierarchy
	# Discover path string from a fresh instance
	var probe = char_ps.instance()
	var sk = _find_skel(probe)
	var rn = sk.get_parent().get_parent()
	var ap_dummy = AnimationPlayer.new()
	probe.add_child(ap_dummy)
	var rn_path = String(ap_dummy.get_path_to(rn))
	probe.free()
	print("thin root_node=", rn_path)

	lines.append('[node name="AnimationPlayer" type="AnimationPlayer" parent="."]')
	lines.append('root_node = NodePath("' + rn_path + '")')
	id = 2
	for clip in clip_names:
		lines.append('anims/' + clip + ' = ExtResource( ' + str(id) + ' )')
		id += 1
	lines.append("")

	var f = File.new()
	f.open(DEST, File.WRITE)
	f.store_string(PoolStringArray(lines).join("\n"))
	f.close()
	print("WROTE thin ", DEST, " clips=", clip_names.size())

func _normalize_tracks(anim, root_node, skel):
	# Tracks from anim GLBs already use Object_4/Skeleton:bone — leave as-is if RootNode is AP root
	return anim

func _find_skel(n):
	if n is Skeleton:
		return n
	for c in n.get_children():
		var f = _find_skel(c)
		if f:
			return f
	return null

func _find_ap(n):
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var f = _find_ap(c)
		if f:
			return f
	return null

func _set_owner_recursive(n, own):
	for c in n.get_children():
		c.owner = own
		_set_owner_recursive(c, own)
