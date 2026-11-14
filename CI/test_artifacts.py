# SPDX-License-Identifier: MIT

from pathlib import Path
import subprocess
import tempfile
import unittest

import artifacts


class ArtifactsTest(unittest.TestCase):
    def test_multiconfig_images(self):
        for machine in ("qemuarm64", "qemux86-64"):
            with self.subTest(machine=machine), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                variants = ["newlib", "baremetal"]
                if machine == "qemuarm64":
                    variants.append("picolibc")
                for libc in variants:
                    tmp = "tmp" if libc == "newlib" else f"tmp-{machine}-{libc}"
                    deploy = root / tmp / "deploy/images" / machine
                    deploy.mkdir(parents=True)
                    for name in ("hello.elf", "hello.bin", "hello.qemuboot.conf",
                                 "hello.manifest", "hello.iso", "ignored.conf"):
                        (deploy / name).write_text(libc)
                    (deploy / "link.elf").symlink_to("hello.elf")
                artifacts.images(root, root / "images", machine)
                self.assertEqual(
                    {path.name for path in (root / "images").iterdir()},
                    {f"{libc}-{name}" for libc in variants for name in (
                        "hello.elf", "hello.bin", "hello.qemuboot.conf",
                        "hello.manifest", "hello.iso",
                    )},
                )

    def test_missing_multiconfig_artifacts_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            deploy = root / "tmp/deploy/images/qemuarm64"
            deploy.mkdir(parents=True)
            (deploy / "hello.elf").write_text("newlib")
            with self.assertRaisesRegex(RuntimeError, "baremetal"):
                artifacts.images(root, root / "images", "qemuarm64")

    def test_native_archive_preserves_download_links_and_hidden_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            downloads = root / "downloads"
            downloads.mkdir()
            (downloads / ".done").write_text("done")
            (downloads / "source").write_text("source")
            (downloads / "link").symlink_to("source")
            archive = root / "native-downloads.tar.zst"
            artifacts.archive(downloads, archive)
            restored = root / "restored"
            restored.mkdir()
            subprocess.run(["tar", "--zstd", "-xf", str(archive), "-C", str(restored)], check=True)
            self.assertEqual((restored / ".done").read_text(), "done")
            self.assertTrue((restored / "link").is_symlink())
            self.assertEqual((restored / "link").read_text(), "source")

    def test_sstate_snapshot_survives_removal_of_mirror(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sstate, mirror = root / "sstate", root / "mirror"
            sstate.mkdir()
            mirror.mkdir()
            (mirror / "fetched").write_bytes(b"cached task")
            (sstate / "fetched").symlink_to(mirror / "fetched")
            (sstate / "new").write_bytes(b"new task")
            artifacts.materialize_sstate(sstate, mirror)
            (mirror / "fetched").unlink()
            mirror.rmdir()
            archive = root / "sstate.tar.zst"
            artifacts.archive(sstate, archive)
            restored = root / "restored"
            restored.mkdir()
            subprocess.run(["tar", "--zstd", "-xf", str(archive), "-C", str(restored)], check=True)
            self.assertFalse((restored / "fetched").is_symlink())
            self.assertEqual((restored / "fetched").read_bytes(), b"cached task")
            self.assertEqual((restored / "new").read_bytes(), b"new task")

    def test_multiconfig_diagnostics(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / "tmp-qemuarm64-baremetal/work/recipe/temp/log.do_compile"
            log.parent.mkdir(parents=True)
            log.write_text("failure")
            artifacts.logs(root, root / "output")
            contents = subprocess.check_output(
                ["tar", "--zstd", "-tf", str(root / "output/diagnostics.tar.zst")],
                text=True,
            )
            self.assertIn(str(log.relative_to(root)), contents)


if __name__ == "__main__":
    unittest.main()
