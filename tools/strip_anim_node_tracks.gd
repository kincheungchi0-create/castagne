extends SceneTree
# Remove non-Skeleton transform tracks (e.g. Object_4 scale 0.01) from Anime Girl .anim files.

const ANIM_DIR = "res://castagne/assets/fighters/animegirl/anims/"

func _init():
	call_deferred("_go")

func _go():
	var d = Directory.new()
	if d.open(ANIM_DIR) != OK:
		printerr("open fail")
		quit(1)
		return
	d.list_dir_begin(true, true)
	var f = d.get_next()
	var nfiles = 0
	while f != "":
		if f.ends_with(".anim"):
			var path = ANIM_DIR + f
			var anim = load(path)
			if anim:
				var removed = _strip(anim)
				var err = ResourceSaver.save(path, anim)
				print(f, " removed=", removed, " tracks_left=", anim.get_track_count(), " save=", err)
				nfiles += 1
		f = d.get_next()
	d.list_dir_end()
	# Verify ginga
	var anim = load(ANIM_DIR + "ginga_variation_1.anim")
	for i in range(anim.get_track_count()):
		var s = String(anim.track_get_path(i))
		if s.find("Skeleton:") < 0:
			print("STILL NON-SKEL ", s)
	# AABB test
	var model = load("res://castagne/assets/fighters/animegirl/AnimeGirlModel.tscn").instance()
	get_root().add_child(model)
	model.scale = Vector3(15,15,15)
	var ap = model.get_node("AnimationPlayer")
	print("AABB bind=", _aabb(model))
	ap.play("ginga_variation_1", -1, 0.0, false)
	ap.seek(0.5, true)
	call_deferred("_done", model)
func _done(model):
	print("AABB anim=", _aabb(model))
	quit()

func _strip(anim):
	var removed = 0
	# remove from end so indices stay valid
	for i in range(anim.get_track_count() - 1, -1, -1):
		var s = String(anim.track_get_path(i))
		# Keep only Skeleton bone tracks
		if s.find("/Skeleton:") < 0 and s.find("Skeleton:") < 0:
			anim.remove_track(i)
			removed += 1
		# Also drop tip bones that don't exist on character (optional - leave, harmless if unresolved)
	return removed

func _aabb(n):
	var acc = null
	for x in _all(n):
		if x is MeshInstance and x.mesh:
			var xf = x.global_transform
			var a = x.get_aabb()
			var g = AABB(xf.xform(a.position), Vector3())
			g = g.expand(xf.xform(a.position + a.size))
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
