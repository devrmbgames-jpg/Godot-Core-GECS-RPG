# Tools Context

Project tooling lives here and is not runtime gameplay code.

- `check_gdscript_docs.py` — scans project-owned `.gd` files and fails when a `func`/`static func` declaration is not preceded by a GDScript `##` doc comment. `addons/` is excluded because GECS is an external submodule.

Run from repository root:

```bash
python tools/check_gdscript_docs.py
```

Use this check after adding or moving GDScript API. It verifies documentation adjacency, not factual quality of the comment.