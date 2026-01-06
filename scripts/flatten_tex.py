#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from typing import List, Set


INPUT_RE = re.compile(r"\\(input|include)\{([^}]+)\}")


def strip_comment(line: str) -> str:
    out = []
    escaped = False
    for ch in line:
        if ch == "%" and not escaped:
            break
        if ch == "\\" and not escaped:
            escaped = True
            out.append(ch)
            continue
        escaped = False
        out.append(ch)
    return "".join(out)


def resolve_tex_path(current_file: Path, raw: str) -> Path:
    raw_path = Path(raw)
    if raw_path.suffix == "":
        raw_path = raw_path.with_suffix(".tex")
    if raw_path.is_absolute():
        return raw_path
    return (current_file.parent / raw_path).resolve()


def flatten(file_path: Path, visited: Set[Path]) -> str:
    file_path = file_path.resolve()
    if file_path in visited:
        return ""
    visited.add(file_path)

    try:
        text = file_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        raise SystemExit(f"Error: no existe el archivo incluido: {file_path}")

    out_lines: List[str] = []
    for line in text.splitlines(keepends=True):
        current = line
        while True:
            scan = strip_comment(current)
            m = INPUT_RE.search(scan)
            if not m:
                break
            arg = m.group(2).strip()
            include_path = resolve_tex_path(file_path, arg)
            before = current[: m.start()]
            after = current[m.end() :]
            expanded = flatten(include_path, visited)
            current = before + expanded + after
        out_lines.append(current)

    return "".join(out_lines)


def main() -> int:
    if len(sys.argv) != 3:
        print("Uso: scripts/flatten_tex.py <main.tex> <salida.tex>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    flattened = flatten(src, visited=set())
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(flattened, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
