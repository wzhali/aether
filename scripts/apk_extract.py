#!/usr/bin/env python3
"""
scripts/apk_extract.py — extract an Alpine / OpenWrt 25.12 .apk package.

Alpine APK format (per apk-tools source):
  - 4-byte magic header: b"apk\\0" for Alpine, or b"ADBd" for OpenWrt 25.12.
    The size of the leading signature depends on the package; we
    detect it dynamically by sniffing the first few bytes after the
    header for a known compression magic.
  - a tar stream compressed with zstd (OpenWrt 25.12 default) or gzip.

This script tries zstd first, then gzip, and gives up after the first
8 KiB of header probing.
"""
from __future__ import annotations

import io
import sys
import tarfile
import zstandard as zstd  # type: ignore
import gzip
from pathlib import Path

# Known compressor magics we can sniff for after the APK signature block.
_ZSTD_MAGIC = b"\x28\xb5\x2f\xfd"
_GZIP_MAGIC = b"\x1f\x8b"
_BZIP2_MAGIC = b"BZh"
_XZ_MAGIC = b"\xfd7zXZ\x00"

MAX_HEADER_PROBE = 64 * 1024  # 64 KiB is enough for any APK signature header.


def find_compressed_offset(blob: bytes) -> int:
    """Return offset where a known compressed-payload magic starts."""
    for magic in (_ZSTD_MAGIC, _GZIP_MAGIC, _BZIP2_MAGIC, _XZ_MAGIC):
        idx = blob.find(magic)
        if idx != -1:
            return idx
    raise ValueError("no zstd/gzip/bzip2/xz magic found inside APK")


def open_compressed(blob: bytes):
    offset = find_compressed_offset(blob)
    header = blob[:offset]
    sys.stderr.write(f"apk_extract: skipped {offset}-byte signature header\n")
    payload = blob[offset:]
    if payload.startswith(_ZSTD_MAGIC):
        dctx = zstd.ZstdDecompressor()
        return dctx.stream_reader(io.BytesIO(payload), closefd=False)
    if payload.startswith(_GZIP_MAGIC):
        return gzip.GzipFile(fileobj=io.BytesIO(payload))
    if payload.startswith(_BZIP2_MAGIC):
        import bz2
        return bz2.BZ2File(io.BytesIO(payload))
    if payload.startswith(_XZ_MAGIC):
        import lzma
        return lzma.LZMAFile(io.BytesIO(payload))
    raise ValueError("matched magic but stream was not readable")


def extract(apk_path: Path, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    with apk_path.open("rb") as f:
        head = f.read(MAX_HEADER_PROBE)
        if not head:
            print("apk_extract: empty file", file=sys.stderr)
            return 2
        try:
            stream = open_compressed(head)
        except ValueError as e:
            print(f"apk_extract: {e}", file=sys.stderr)
            return 3
        with tarfile.open(fileobj=stream) as tf:
            tf.extractall(out_dir, filter="data")
    print(f"Extracted {apk_path} -> {out_dir}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: apk_extract.py <file.apk> <out_dir>", file=sys.stderr)
        sys.exit(1)
    sys.exit(extract(Path(sys.argv[1]), Path(sys.argv[2])))