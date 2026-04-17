#!/usr/bin/env python3
#=========================================================================
# pipes/tb/gen_pipevecs.py
#=========================================================================
# Sebastian Claudiusz Magierowski Apr 17 2026

from __future__ import annotations

import argparse
from pathlib import Path


def make_msg(idx: int) -> int:
    digit = idx + 1
    return (digit << 4) | digit


def render_vector_lines(stages: int, count: int) -> str:
    lines: list[str] = []
    lines.append(f"// Auto-generated vectors for a {stages}-stage pipe with {count} inputs")
    for idx in range(count):
        src = make_msg(idx)
        snk = src + stages
        lines.append(f"init_data_src( 64'h{src:016x} );")
    lines.append("")
    for idx in range(count):
        src = make_msg(idx)
        snk = src + stages
        lines.append(f"init_data_snk( 64'h{snk:016x} );")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate simple pipe test vectors.")
    parser.add_argument("--stages", type=int, required=True, help="Number of +1 stages in the pipe.")
    parser.add_argument("--count", type=int, required=True, help="Number of test vectors.")
    parser.add_argument("--output", type=Path, required=True, help="Output include file.")
    args = parser.parse_args()

    if args.stages < 0:
        raise SystemExit("--stages must be non-negative")
    if args.count < 0:
        raise SystemExit("--count must be non-negative")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render_vector_lines(args.stages, args.count), encoding="ascii")


if __name__ == "__main__":
    main()
