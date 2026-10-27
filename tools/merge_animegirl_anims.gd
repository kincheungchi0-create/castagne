extends SceneTree
# Merge Capoeira GLB clips into AnimeGirlModel.tscn AnimationPlayer (Godot 3.5).

const MODEL_DIR = "res://castagne/assets/fighters/animegirl/models/"
const DEST_TSN = "res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn"

func _init():
	call_deferred("_go")

func _go():
	var dest_ps = load(DEST_TSN)
	if dest_ps == null:
		printerr("FAIL load ", DEST_TSN)
		quit(1)
		return
	var root = dest_ps.instance()
	var ap = root.get_node("AnimationPlayer")
	if ap == null:
		ap = AnimationPlayer.new()
		ap.name = "AnimationPlayer"
		root.add_child(ap)
	ap.root_node = NodePath("..")

	var dir = Directory.new()
	if dir.open(MODEL_DIR) != OK:
		printerr("FAIL open ", MODEL_DIR)
		quit(1)
		return
	dir.list_dir_begin(true, true)
	var fname = dir.get_next()
	var added = 0
	var skipped = 0
	while fname != "":
		if fname.ends_with(".glb") and fname != "character.glb":
			var clip = fname.get_basename()
			var path = MODEL_DIR + fname
			var ps = load(path)
			if ps == null:
				printerr("skip load fail ", path)
				skipped += 1
			else:
				var inst = ps.instance()
				var src_ap = _find_ap(inst)
				if src_ap == null or src_ap.get_animation_list().empty():
					printerr("skip no anim ", clip)
					skipped += 1
				else:
					var src_name = src_ap.get_animation_list()[0]
					var anim = src_ap.get_animation(src_name).duplicate(true)
					if ap.has_animation(clip):
						ap.remove_animation(clip)
					ap.add_animation(clip, anim)
					added += 1
					print("OK ", clip, " (from ", src_name, ", length=", anim.length, " tracks=", anim.get_track_count(), ")")
				inst.free()
		fname = dir.get_next()
	dir.list_dir_end()

	_set_owner_recursive(root, root)
	var out = PackedScene.new()
	var err = out.pack(root)
	if err != OK:
		printerr("pack fail ", err)
		quit(1)
		return
	err = ResourceSaver.save(DEST_TSN, out)
	print("SAVE ", DEST_TSN, " err=", err, " added=", added, " skipped=", skipped)
	print("ANIM_LIST ", ap.get_animation_list())
	root.free()
	quit(0 if err == OK else 1)

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
