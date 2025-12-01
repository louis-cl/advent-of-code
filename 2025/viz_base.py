"""Base class for Pyxel visualizations with MP4 export."""
import subprocess
import tempfile
import os
from pathlib import Path

import pyxel


class Visualization:
    """Base class for AoC visualizations.

    Subclass and override:
        - update(): called each frame for logic
        - draw(): called each frame for rendering

    Press R to start/stop recording, Q to quit.
    """

    def __init__(self, width=256, height=256, title="AoC 2025", fps=30):
        self.width = width
        self.height = height
        self.fps = fps
        self.recording = False
        self.frames = []
        self.output_path = None

        pyxel.init(width, height, title=title, fps=fps)

    def run(self, output_path=None):
        """Start the visualization. If output_path is set, auto-record and exit."""
        self.output_path = output_path
        if output_path:
            self.recording = True
        pyxel.run(self._update, self._draw)

    def _update(self):
        if pyxel.btnp(pyxel.KEY_Q):
            self._finish()
            pyxel.quit()
            return

        if pyxel.btnp(pyxel.KEY_R):
            self.recording = not self.recording
            if not self.recording and self.frames:
                self._export_mp4()
                self.frames = []

        self.update()

    def _draw(self):
        self.draw()

        if self.recording:
            self._capture_frame()
            pyxel.text(2, 2, "REC", 8)

    def _capture_frame(self):
        """Capture current frame as raw pixel data."""
        frame = []
        for y in range(self.height):
            row = []
            for x in range(self.width):
                row.append(pyxel.pget(x, y))
            frame.append(row)
        self.frames.append(frame)

    def _finish(self):
        """Called when quitting. Export if recording."""
        if self.recording and self.frames:
            self._export_mp4()

    def _export_mp4(self, path=None):
        """Export captured frames to MP4 using ffmpeg."""
        if not self.frames:
            print("No frames to export")
            return

        path = path or self.output_path or "output.mp4"
        print(f"Exporting {len(self.frames)} frames to {path}...")

        # Pyxel palette (16 colors)
        palette = [
            (0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81),
            (171, 82, 54), (95, 87, 79), (194, 195, 199), (255, 241, 232),
            (255, 0, 77), (255, 163, 0), (255, 236, 39), (0, 228, 54),
            (41, 173, 255), (131, 118, 156), (255, 119, 168), (255, 204, 170),
        ]

        with tempfile.TemporaryDirectory() as tmpdir:
            # Write frames as raw RGB
            raw_path = os.path.join(tmpdir, "frames.raw")
            with open(raw_path, 'wb') as f:
                for frame in self.frames:
                    for row in frame:
                        for color_idx in row:
                            r, g, b = palette[color_idx]
                            f.write(bytes([r, g, b]))

            # Encode with ffmpeg - high quality MP4
            cmd = [
                'ffmpeg', '-y',
                '-f', 'rawvideo',
                '-pixel_format', 'rgb24',
                '-video_size', f'{self.width}x{self.height}',
                '-framerate', str(self.fps),
                '-i', raw_path,
                '-vf', 'scale=iw*4:ih*4:flags=neighbor',
                '-c:v', 'libx264',
                '-pix_fmt', 'yuv444p',
                '-crf', '15',
                '-preset', 'slow',
                path
            ]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"ffmpeg error: {result.stderr}")

        print(f"Exported to {path}")

    def update(self):
        """Override this for update logic."""
        pass

    def draw(self):
        """Override this for drawing."""
        pyxel.cls(0)
