#!/usr/bin/env python3
"""Checks that the filegroups in sources.bp match upstream's source lists.

sources.bp describes BoringSSL's source lists with globs. Upstream's source of
truth is src/gen/sources.json. This test compares what Soong actually resolved
for each filegroup (recorded by the boringssl_sources_manifest genrule) against
the matching list in sources.json, and fails with the exact files that differ.
"""

import json
import os
import unittest

EXPECTED = {
    "boringssl_bcm_srcs": ("bcm", "srcs"),
    "boringssl_bcm_asm": ("bcm", "asm"),
    "boringssl_crypto_srcs": ("crypto", "srcs"),
    "boringssl_crypto_asm": ("crypto", "asm"),
    "boringssl_test_support_srcs": ("test_support", "srcs"),
    "boringssl_test_support_asm": ("test_support", "asm"),
    "boringssl_ssl_srcs": ("ssl", "srcs"),
    "boringssl_bssl_srcs": ("bssl", "srcs"),
    "boringssl_pki_srcs": ("pki", "srcs"),
    "boringssl_crypto_test_srcs": ("crypto_test", "srcs"),
    "boringssl_crypto_test_data": ("crypto_test", "data"),
    "boringssl_ssl_test_srcs": ("ssl_test", "srcs"),
}

MANIFEST = "boringssl_sources_manifest.jsonl"
SOURCES_JSON = os.path.join("src", "gen", "sources.json")


def load_manifest(path):
    """Returns {filegroup: set of paths relative to src/} from the manifest."""
    with open(path, encoding="utf-8") as f:
        rows = [json.loads(line) for line in f]
    sources_json = next(p for name, p in rows if name == "sources_json")
    src = os.path.dirname(os.path.dirname(sources_json))
    groups = {}
    for name, file_path in rows:
        if name != "sources_json":
            groups.setdefault(name, set()).add(os.path.relpath(file_path, src))
    return groups


def describe_mismatch(group, target, key, only_upstream, only_ours):
    lines = [f"Filegroup {group} no longer matches upstream {target}.{key} in sources.json"]
    if only_upstream:
        lines.append("only upstream:")
        lines += [f"  src/{f}" for f in sorted(only_upstream)]
    if only_ours:
        lines.append("only ours:")
        lines += [f"  src/{f}" for f in sorted(only_ours)]
    return "\n".join(lines)


class SourcesGlobsTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.groups = load_manifest(MANIFEST)
        with open(SOURCES_JSON, encoding="utf-8") as f:
            cls.sources = json.load(f)

    def test_filegroups_match_upstream(self):
        mismatches = []
        for group, (target, key) in EXPECTED.items():
            upstream = set(self.sources.get(target, {}).get(key, []))
            ours = self.groups.get(group, set())
            if upstream != ours:
                mismatches.append(
                    describe_mismatch(group, target, key, upstream - ours, ours - upstream))
        if mismatches:
            self.fail("\n\n".join(mismatches))

    def test_every_filegroup_is_checked(self):
        unknown = sorted(set(self.groups) - set(EXPECTED))
        self.assertFalse(
            unknown,
            f"filegroups in the manifest without an entry in EXPECTED: {unknown}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
