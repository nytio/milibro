#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path


LINE_RE = re.compile(r"^\s*(?P<file>[^:]+):(?P<line>\d+):\s?(?P<text>.*)$")


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "Uso: scripts/languagetool_prepare.py <detex_-1.txt> <salida_texto.txt> <salida_map.json>",
            file=sys.stderr,
        )
        return 2

    detex_with_prefix = Path(sys.argv[1])
    out_text = Path(sys.argv[2])
    out_map = Path(sys.argv[3])

    raw = detex_with_prefix.read_text(encoding="utf-8", errors="replace").splitlines(
        keepends=True
    )

    mapping: list[dict] = []
    text_lines: list[str] = []

    for line in raw:
        m = LINE_RE.match(line.rstrip("\n"))
        if not m:
            mapping.append({"file": None, "line": None})
            text_lines.append(line)
            continue

        mapping.append({"file": m.group("file"), "line": int(m.group("line"))})
        text_lines.append(m.group("text") + "\n")

    out_text.parent.mkdir(parents=True, exist_ok=True)
    out_text.write_text("".join(text_lines), encoding="utf-8")

    out_map.parent.mkdir(parents=True, exist_ok=True)
    out_map.write_text(json.dumps(mapping, ensure_ascii=False), encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

