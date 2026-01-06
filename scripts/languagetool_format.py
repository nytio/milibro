#!/usr/bin/env python3
import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Pos:
    line_index: int
    col: int


def offset_to_line_col(text: str, offset: int) -> Pos:
    if offset < 0:
        offset = 0
    if offset > len(text):
        offset = len(text)

    line_index = text.count("\n", 0, offset)
    line_start = text.rfind("\n", 0, offset)
    if line_start == -1:
        line_start = 0
    else:
        line_start += 1
    col = (offset - line_start) + 1
    return Pos(line_index=line_index, col=col)


def caret_context(ctx_text: str, ctx_offset: int, length: int) -> str:
    if length < 1:
        length = 1
    caret_line = " " * ctx_offset + "^" + ("~" * (length - 1))
    return f"{ctx_text}\n{caret_line}"


def main() -> int:
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--source", required=True, help="archivo original revisado (para imprimir)")
    ap.add_argument("--text", required=True, help="texto enviado a LanguageTool (sin prefijos)")
    ap.add_argument("--map", required=True, help="mapa JSON de líneas (salida de languagetool_prepare.py)")
    ap.add_argument("--json", required=True, help="respuesta JSON de LanguageTool")
    ap.add_argument(
        "--only",
        default="",
        choices=["", "misspelling"],
        help="filtra issues por tipo (p.ej. 'misspelling')",
    )
    ap.add_argument("--max", type=int, default=200, help="máximo de issues a mostrar por archivo")
    args = ap.parse_args()

    source = args.source
    text = Path(args.text).read_text(encoding="utf-8", errors="replace")
    mapping = json.loads(Path(args.map).read_text(encoding="utf-8"))
    resp = json.loads(Path(args.json).read_text(encoding="utf-8"))

    matches = resp.get("matches", [])
    if args.only:
        matches = [m for m in matches if (m.get("rule", {}) or {}).get("issueType") == args.only]
    if not matches:
        suffix = " (sin sugerencias)"
        if args.only:
            suffix = f" (sin sugerencias de tipo '{args.only}')"
        print(f"{source}: OK{suffix}")
        return 0

    print(f"{source}: {len(matches)} sugerencia(s)")

    shown = 0
    for m in matches:
        if shown >= args.max:
            print(f"{source}: ... (truncado a {args.max})")
            break

        rule = m.get("rule", {}) or {}
        rule_id = rule.get("id", "unknown")
        message = m.get("message", "").strip()
        offset = int(m.get("offset", 0))
        length = int(m.get("length", 0))

        pos = offset_to_line_col(text, offset)
        original_line = pos.line_index + 1
        if 0 <= pos.line_index < len(mapping):
            mapped_line = mapping[pos.line_index].get("line")
            if isinstance(mapped_line, int):
                original_line = mapped_line

        repl = [r.get("value", "") for r in (m.get("replacements", []) or [])]
        repl = [x for x in repl if x][:5]
        repl_txt = ""
        if repl:
            repl_txt = f" | sugerencias: {', '.join(repl)}"

        print(f"- {source}:{original_line}:{pos.col} [{rule_id}] {message}{repl_txt}")

        ctx = m.get("context", {}) or {}
        ctx_text = ctx.get("text", "")
        ctx_offset = int(ctx.get("offset", 0))
        print(caret_context(ctx_text, ctx_offset, length))
        print()

        shown += 1

    return 1


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        sys.stderr.close()
        raise
