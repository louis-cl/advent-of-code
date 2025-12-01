#!/usr/bin/env python3
import sys
import math
from pathlib import Path
import pyxel

sys.path.insert(0, str(Path(__file__).parent.parent))
from viz_base import Visualization


class DayViz(Visualization):
    def __init__(self, data):
        super().__init__(width=200, height=140, title="Day 1: Safe Dial", fps=60)
        self.instructions = [line.strip() for line in data.strip().split('\n')]

        self.step = 0
        self.count_p1 = 0
        self.count_p2 = 0
        self.finished = False

        # Ground truth: actual dial position
        self.dial = 50
        self.target_dial = 50

        # Animation state
        self.animating = False
        self.anim_angle = self.dial_to_angle(50)  # Current visual angle during animation
        self.remaining_rotation = 0
        self.rotation_speed = 0.05  # Radians per frame

        self.p1_timer = 0
        self.p2_timer = 0
        self.zero_timer = 0

    def dial_to_angle(self, pos):
        return (pos / 100.0) * 2 * math.pi - math.pi / 2

    def angle_to_dial(self, angle):
        return int(((angle + math.pi / 2) % (2 * math.pi)) / (2 * math.pi) * 100) % 100

    def draw_dial(self, cx, cy, r):
        """Draw the fixed dial elements (circle, ticks, labels)."""
        # Dial circle
        pyxel.circb(cx, cy, r, 7)

        # Tick marks
        for i in range(0, 100, 10):
            a = self.dial_to_angle(i)
            pyxel.line(cx + int((r - 5) * math.cos(a)), cy + int((r - 5) * math.sin(a)),
                      cx + int(r * math.cos(a)), cy + int(r * math.sin(a)), 7)
        for i in range(0, 100, 5):
            if i % 10:
                a = self.dial_to_angle(i)
                pyxel.line(cx + int((r - 3) * math.cos(a)), cy + int((r - 3) * math.sin(a)),
                          cx + int(r * math.cos(a)), cy + int(r * math.sin(a)), 6)

        # Number labels
        for n in [25, 50, 75]:
            a = self.dial_to_angle(n)
            pyxel.text(cx + int((r + 10) * math.cos(a)) - len(str(n)) * 2,
                      cy + int((r + 10) * math.sin(a)) - 3, str(n), 7)

    def update(self):
        # Speed controls
        if pyxel.btnp(pyxel.KEY_UP):
            self.rotation_speed = min(self.rotation_speed * 1.5, 1.0)  # Max speed
        if pyxel.btnp(pyxel.KEY_DOWN):
            self.rotation_speed = max(self.rotation_speed / 1.5, 0.01)  # Min speed

        self.p1_timer = max(0, self.p1_timer - 1)
        self.p2_timer = max(0, self.p2_timer - 1)
        self.zero_timer = max(0, self.zero_timer - 1)

        if self.finished:
            if not hasattr(self, 'finish_timer'):
                self.finish_timer = 60  # 1 second at 60fps
            self.finish_timer -= 1
            if self.finish_timer <= 0 and self.output_path:
                self._finish()
                pyxel.quit()
            return

        if not self.animating and self.step < len(self.instructions):
            line = self.instructions[self.step]
            sign = 1 if line[0] == 'R' else -1
            mag = int(line[1:])

            # Calculate new dial position (ground truth) - Part 2 logic
            q, new_dial = divmod(self.dial + sign * mag, 100)

            # Calculate P2 count for this instruction (from your solution)
            p2_for_this_step = abs(q)
            if sign == -1 and new_dial == 0:
                p2_for_this_step += 1
            if sign == -1 and self.dial == 0:
                p2_for_this_step -= 1

            # Store for triggering visual effect
            self.p2_count_this_step = p2_for_this_step
            self.p2_triggered = False  # Track if we've shown the visual effect

            # Set up animation
            self.target_dial = new_dial
            self.remaining_rotation = (mag / 100.0) * 2 * math.pi * sign
            self.animating = True
            self.step += 1

        elif self.animating:
            # Track position for zero crossing detection
            old_dial = int(((self.anim_angle + math.pi / 2) % (2 * math.pi)) / (2 * math.pi) * 100) % 100

            if abs(self.remaining_rotation) <= self.rotation_speed:
                # Finish animation - snap to target
                self.anim_angle += self.remaining_rotation
                self.dial = self.target_dial
                self.remaining_rotation = 0
                self.animating = False

                # P1: Count landing on 0 (at end of instruction) - from part1 solution
                if self.dial == 0:
                    self.count_p1 += 1
                    self.p1_timer = 20
                    self.zero_timer = 15

                # P2: If we haven't triggered visual effect yet and count > 0, trigger at end
                if not self.p2_triggered and self.p2_count_this_step > 0:
                    self.count_p2 += self.p2_count_this_step
                    self.p2_timer = 20
                    self.zero_timer = 15

                if self.step >= len(self.instructions):
                    self.finished = True
            else:
                # Animate
                step = self.rotation_speed if self.remaining_rotation > 0 else -self.rotation_speed
                self.anim_angle += step
                self.remaining_rotation -= step

            # P2: Trigger visual effect on first zero crossing
            new_dial = int(((self.anim_angle + math.pi / 2) % (2 * math.pi)) / (2 * math.pi) * 100) % 100
            if old_dial != new_dial and new_dial == 0 and not self.p2_triggered and self.p2_count_this_step > 0:
                self.count_p2 += self.p2_count_this_step
                self.p2_triggered = True
                self.p2_timer = 20
                self.zero_timer = 15

    def draw(self):
        pyxel.cls(1)

        cx, cy, r = 85, 75, 40

        # Draw fixed dial elements
        self.draw_dial(cx, cy, r)

        # Zero marker (changes color on trigger)
        za = self.dial_to_angle(0)
        pyxel.text(cx + int((r + 10) * math.cos(za)) - 2, cy + int((r + 10) * math.sin(za)) - 3,
                  "0", 10 if self.zero_timer else 7)

        # Pointer
        pyxel.circ(cx, cy, 2, 6)
        angle = self.anim_angle if self.animating else self.dial_to_angle(self.dial)
        ax = cx + int((r - 5) * math.cos(angle))
        ay = cy + int((r - 5) * math.sin(angle))
        pyxel.line(cx, cy, ax, ay, 10)
        pyxel.circ(ax, ay, 1, 10)

        # Current position (use ground truth when not animating)
        pos = self.dial if not self.animating else int(((self.anim_angle + math.pi / 2) % (2 * math.pi)) / (2 * math.pi) * 100) % 100
        pyxel.text(cx - 3, cy - 15, f"{pos:02d}", 7)

        # State
        pyxel.text(5, 5, f"P1: {self.count_p1}", 10 if self.p1_timer else 11)
        pyxel.text(5, 13, f"P2: {self.count_p2}", 10 if self.p2_timer else 11)
        pyxel.text(5, 21, f"Step: {self.step}/{len(self.instructions)}", 7)
        pyxel.text(5, 29, f"Speed: {self.rotation_speed:.2f}x", 6)

        # Instruction list
        idx = self.step - 1 if self.step > 0 else 0
        start = max(0, idx - 5)
        for i in range(start, min(len(self.instructions), start + 15)):
            y = 5 + (i - start) * 8
            if i == idx and self.step > 0:
                pyxel.rect(153, y - 1, 40, 7, 2)
                pyxel.text(155, y, self.instructions[i], 10)
            else:
                pyxel.text(155, y, self.instructions[i], 6)


if __name__ == '__main__':
    input_file = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] != "--export" else Path(__file__).parent / "input.txt"
    data = Path(input_file).read_text()
    viz = DayViz(data)
    export = "--export" in sys.argv
    viz.run(output_path="viz.mp4" if export else None)
