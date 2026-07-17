#!/usr/bin/env python3
"""
scripts/apk_extract.py — extract an Alpine .apk package using only stdlib.

Alpine .apk format (per apk-tools source):
  - 8-byte magic header ("ADBd" 0x00 ... -- we just skip it)
  - then a gzip stream containing a tar archive

This is enough for the install-check step in CI; we don't need a full
apk-tools binary.
"""
from __future__ import annotations

import gzip
import sys
import tarfile
from pathlib import Path

SKIP_HEADER_BYTES = 8  # Alpine APK: 8-byte signature header before the gzip stream.


def extract(apk_path: Path, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    with apk_path.open("rb") as f:
        header = f.read(SKIP_HEADER_BYTES)
        if not header:
            print(f"apk_extract: empty file: {apk_path}", file=sys.stderr)
            return 2
        # Pass the remaining bytes straight to gzip / tarfile.
        remaining = f.read()
    try:
        with tarfile.open(fileobj=gzip.GzipFile(fileobj=__import__("io").BytesIO(remaining))) as tf:
            tf.extractall(out_dir, filter="data")
    except (gzip.BadGzipFile, tarfile.TarError) as e:
        print(f"apk_extract: not a valid apk: {e}", file=sys.stderr)
        return 3
    print(f"Extracted {apk_path} -> {out_dir}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: apk_extract.py <file.apk> <out_dir>", file=sys.stderr)
        sys.exit(1)
    sys.exit(extract(Path(sys.argv[1]), Path(sys.argv[2])))