# Anime Girl fighter pack (Castagne / Godot 3)

Starter assets so Castagne can load the **Anime Girl** (sketchgirl) mesh and Capoeira clips.

## Layout

| Path | Purpose |
|------|---------|
| `models/character.glb` | Base mesh + skin (no animation clips) |
| `models/*.glb` | One Capoeira clip per file (skin + animation, no mesh) |
| `AnimeGirlModel.tscn` | Godot 3 scene Castagne `GRAPHICS_ModelPath` points at |
| `CREDITS.md` | CC BY 4.0 attribution |

CASP helpers (this fork):

- `examples/fighters/animegirl/AnimeGirl-Model.casp` — name, model path, `ANIM_*` → clip map
- `examples/fighters/animegirl/AnimeGirl-25D.casp` — thin fighter with stub attacks (`Skeleton` → Model casp)

## Godot version

Upstream Castagne targets **Godot 3**. Open the Castagne project (select `project.godot` from a full Castagne download, or link this `castagne/` folder as `res://castagne` in your game project).

## Import recipe (AnimationPlayer)

`character.glb` has mesh/skin only. Each other GLB holds one named clip (e.g. `martelo_2`). Merge them once in the editor:

1. Open the Castagne / Godot 3 project and let Godot import every file under `assets/fighters/animegirl/models/`.
2. Open `AnimeGirlModel.tscn` (or **Scene → New Inherited Scene** from `character.glb`).
3. Select the root; confirm an **AnimationPlayer** (or **AnimationTree**) exists on the imported skeleton. If missing, add an `AnimationPlayer` node as a child of the armature root Castagne will use (`GRAPHICS_ModelPath_AnimPlayer` defaults to `AnimationPlayer`).
4. For each animation GLB (everything except `character.glb`):
   - Open the imported GLB scene temporarily (or use the Animation panel **Animation → Manage Animations / Make Unique** workflow).
   - Copy the clip into `AnimeGirlModel.tscn`'s AnimationPlayer. Keep the **clip name equal to the GLB basename** (`ginga_variation_1`, `armada`, …) so it matches `AnimeGirl-Model.casp`.
5. Save `AnimeGirlModel.tscn`. Optional: delete temporary inherited scenes of the anim-only GLBs.
6. In the Castagne editor, add character `AnimeGirl-25D.casp` (or New Character with Skeleton = `AnimeGirl-Model.casp`).

CLI note: merging dozens of GLB AnimationPlayers without the Godot GUI is brittle; this pack ships the raw GLBs + the intended name map instead. After one editor import pass, clips play via `Anim(clip_name)` in CASP.

## `ANIM_*` map (summary)

| Castagne slot family | Clip(s) used |
|----------------------|--------------|
| Stand / intro | `ginga_variation_1` |
| Walk F / B | `ginga_forward` / `ginga_backward` |
| Crouch / low block | `esquiva_3` |
| Jump / air idle | `au` |
| Dash / step | `ginga_sideways_1`, `ginga_sideways_2`, `ginga_sideways_to_au` |
| Block / hitstun | `esquiva_1` … `esquiva_5` |
| Knockdown / dead | `au_to_role`, wakeup `macaco_side` |
| Win | `capoeira` |
| Stub attacks (25D) | `martelo_2`, `armada`, `meia_lua_de_frente`, `rasteira_1`, `chapa_2`, `bencao`, `martelo_do_chau`, `au` |

Full define list: `examples/fighters/animegirl/AnimeGirl-Model.casp`.

## Unmapped clips (available, not wired to a default `ANIM_*`)

Use these for specials / supers later:

- `ginga_variation_2`, `ginga_variation_3`
- `martelo_3`, `martelo_do_chau_sem_mao`
- `armada_to_esquiva`
- `chapa_giratoria`, `chapa_giratoria_2`, `chapaeu_de_couro`
- `meia_lua_de_compasso`, `meia_lua_de_compasso_back`
- `pontera`, `queshada_1`, `queshada_2`, `rasteira_2`
- `capoeira_2`, `capoeira_3`, `troca_1` (also used as turnaround)

## Open in Castagne

1. Use a Castagne + Godot 3 install ([download](https://castagneengine.com/download/)).
2. Ensure this repo folder is available as `res://castagne` (same layout as upstream).
3. Import animations (section above).
4. Editor → add `res://castagne/examples/fighters/animegirl/AnimeGirl-25D.casp`.
