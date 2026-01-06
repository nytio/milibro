#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from typing import Dict, List, Set


INPUT_RE = re.compile(r"\\(input|include)\{([^}]+)\}")
MILIBRO_CHAPTER_RE = re.compile(r"\\milibroChapter\{([^}]+)\}")
LIBRO_TEXDIR_DEF_RE = re.compile(r"\\def\\LibroTexDir\{([^}]+)\}")
LIBRO_TEXDIR_CMD_RE = re.compile(
    r"\\(?:re)?(?:newcommand|providecommand)\{\\LibroTexDir\}\{([^}]+)\}"
)


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


def find_repo_root(start: Path) -> Path:
    for parent in [start.resolve(), *start.resolve().parents]:
        if (parent / "tex" / "milibro.tex").is_file() and (parent / "tex").is_dir():
            return parent
        if (parent / "milibro.tex").is_file() and (parent / "tex").is_dir():
            return parent
    return start.resolve().parent


def resolve_tex_path(current_file: Path, raw: str, repo_root: Path) -> Path:
    raw_path = Path(raw)
    if raw_path.suffix == "":
        raw_path = raw_path.with_suffix(".tex")
    if raw_path.is_absolute():
        return raw_path
    candidate = (current_file.parent / raw_path).resolve()
    if candidate.exists():
        return candidate
    candidate2 = (repo_root / raw_path).resolve()
    if candidate2.exists():
        return candidate2
    return candidate


def resolve_milibro_chapter_path(repo_root: Path, tex_dir: str, raw: str) -> Path:
    raw_path = Path(raw)
    if raw_path.suffix == "":
        raw_path = raw_path.with_suffix(".tex")
    if raw_path.is_absolute():
        return raw_path
    return (repo_root / tex_dir / raw_path).resolve()


def update_tex_dir_from_line(line: str, context: Dict[str, str]) -> None:
    scan = strip_comment(line)
    m = LIBRO_TEXDIR_DEF_RE.search(scan)
    if m:
        context["tex_dir"] = m.group(1).strip()
        return
    m2 = LIBRO_TEXDIR_CMD_RE.search(scan)
    if m2:
        context["tex_dir"] = m2.group(1).strip()


def expand_known_macros(raw: str, context: Dict[str, str]) -> str:
    # Soporte mínimo para este repo: \input{\LibroTexDir/...}
    return raw.replace(r"\LibroTexDir", context["tex_dir"])


def flatten(file_path: Path, visited: Set[Path], repo_root: Path, context: Dict[str, str]) -> str:
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
        update_tex_dir_from_line(line, context)

        current = line
        pos = 0
        while True:
            scan = strip_comment(current)

            m_input = INPUT_RE.search(scan, pos)
            m_chap = MILIBRO_CHAPTER_RE.search(scan, pos)

            candidates = [m for m in (m_input, m_chap) if m]
            if not candidates:
                break

            m = min(candidates, key=lambda x: x.start())

            if m.re is MILIBRO_CHAPTER_RE:
                arg = m.group(1).strip()
                include_path = resolve_milibro_chapter_path(repo_root, context["tex_dir"], arg)
            else:
                arg = m.group(2).strip()
                if "#" in arg:
                    pos = m.end()
                    continue
                arg = expand_known_macros(arg, context)
                include_path = resolve_tex_path(file_path, arg, repo_root=repo_root)

            before = current[: m.start()]
            after = current[m.end() :]
            expanded = flatten(include_path, visited, repo_root=repo_root, context=context)
            current = before + expanded + after
            pos = len(before) + len(expanded)

        out_lines.append(current)

    return "".join(out_lines)


def main() -> int:
    if len(sys.argv) != 3:
        print("Uso: scripts/flatten_tex.py <main.tex> <salida.tex>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    repo_root = find_repo_root(src)
    context: Dict[str, str] = {"tex_dir": "tex"}
    flattened = flatten(src, visited=set(), repo_root=repo_root, context=context)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(flattened, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
