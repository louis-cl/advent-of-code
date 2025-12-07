#!/usr/bin/env python3
import sys
import math
from pathlib import Path
from collections import defaultdict

sys.path.insert(0, str(Path(__file__).parent.parent))
from viz_base import Visualization

# Window settings
GRID_SIZE = 141
PADDING = 4
WINDOW_SIZE = GRID_SIZE + 2 * PADDING  # 1 pixel per cell + padding

# Colors by usage
BACKGROUND = 0
SPLITTER = 1  # Dark blue for splitters
START_MARKER = 12  # Cyan

# Heat map scale (low to high intensity)
SCALE_1 = 2   # Dark purple
SCALE_2 = 8   # Red/Magenta
SCALE_3 = 9   # Orange
SCALE_4 = 10  # Yellow
SCALE_5 = 7   # White (peak)


class Day7Viz(Visualization):
    def __init__(self, data):
        super().__init__(width=WINDOW_SIZE, height=WINDOW_SIZE, title="Day 7: Beam Cascade", fps=30)

        # Parse grid and find start position
        self.grid = {}
        self.start = None
        for r, line in enumerate(data.strip().split('\n')):
            for c, char in enumerate(line):
                pos = c + r * 1j
                if char == 'S':
                    self.start = pos
                else:
                    self.grid[pos] = char

        # Simulation state (tracks beam counts at each position)
        self.current_beams = defaultdict(int)
        self.current_beams[self.start] = 1
        self.visit_history = defaultdict(int)
        self.finished = False

    def update(self):
        if self.finished:
            if self.output_path:
                self._finish()
                import pyxel
                pyxel.quit()
            return

        if not self.current_beams:
            self.finished = True
            return

        # Simulate one step: move all beams down one row
        new_beams = defaultdict(int)
        for pos, count in self.current_beams.items():
            next_pos = pos + 1j
            if next_pos not in self.grid:
                continue

            self.visit_history[next_pos] += count

            if self.grid[next_pos] == '.':
                new_beams[next_pos] += count
            else:  # '^' splitter
                new_beams[next_pos - 1] += count
                new_beams[next_pos + 1] += count

        self.current_beams = new_beams

    def draw(self):
        import pyxel
        pyxel.cls(BACKGROUND)

        # Draw heat map (historical beam paths)
        for pos, count in self.visit_history.items():
            pyxel.pset(int(pos.real) + PADDING, int(pos.imag) + PADDING, self.get_color(count))

        # Draw splitters
        for pos, cell in self.grid.items():
            if cell == '^':
                pyxel.pset(int(pos.real) + PADDING, int(pos.imag) + PADDING, SPLITTER)

        # Draw start marker
        pyxel.pset(int(self.start.real) + PADDING, int(self.start.imag) + PADDING, START_MARKER)

        # Draw active beams
        for pos, count in self.current_beams.items():
            pyxel.pset(int(pos.real) + PADDING, int(pos.imag) + PADDING, self.get_color(count))

    def get_color(self, beam_count):
        """Map beam count to color using log scale."""
        if beam_count == 0:
            return BACKGROUND

        log_val = math.log10(beam_count)

        if log_val < 2.0:    # 1-100
            return SCALE_1
        elif log_val < 5.0:  # 100-100K
            return SCALE_2
        elif log_val < 8.0:  # 100K-100M
            return SCALE_3
        elif log_val < 11.0: # 100M-100B
            return SCALE_4
        else:                # 100B+
            return SCALE_5


if __name__ == '__main__':
    input_file = Path(__file__).parent / "input.txt"
    if len(sys.argv) > 1 and sys.argv[1] != "--export":
        input_file = Path(sys.argv[1])

    viz = Day7Viz(input_file.read_text())
    viz.run(output_path="viz.mp4" if "--export" in sys.argv else None)
