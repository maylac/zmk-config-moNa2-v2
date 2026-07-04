#!/usr/bin/env python3
"""Generate an STL for an Accu ZTAE38CXM12C-AL style thread adapter.

All dimensions are in millimetres. STL files do not store units, so import the
result into slicers as mm.
"""

from __future__ import annotations

import math
import struct
from pathlib import Path


OUT = Path(__file__).with_name(
    "accu_ZTAE38CXM12C_AL_3-8-16UNC_to_M12x1.75.stl"
)

MM_PER_INCH = 25.4
SEGMENTS = 144
SAMPLES_PER_PITCH = 24

# Nominal product dimensions from the Accu page.
UNC_MAJOR = 3.0 / 8.0 * MM_PER_INCH
UNC_PITCH = MM_PER_INCH / 16.0
UNC_LENGTH = 5.0 / 8.0 * MM_PER_INCH
M12_MAJOR = 12.0
M12_PITCH = 1.75
M12_LENGTH = 3.0 / 4.0 * MM_PER_INCH
HEX_AF = 3.0 / 4.0 * MM_PER_INCH
HEX_LENGTH = 3.0 / 8.0 * MM_PER_INCH

THREAD_ROOT_FACTOR = 1.226869
CREST_FLAT = 0.10
ROOT_FLAT = 0.10


Triangle = tuple[
    tuple[float, float, float],
    tuple[float, float, float],
    tuple[float, float, float],
]


triangles: list[Triangle] = []


def add_tri(a: tuple[float, float, float], b: tuple[float, float, float], c: tuple[float, float, float]) -> None:
    triangles.append((a, b, c))


def thread_root_diameter(major: float, pitch: float) -> float:
    return major - THREAD_ROOT_FACTOR * pitch


def thread_radius(major: float, root: float, pitch: float, z_rel: float, theta: float) -> float:
    """Approximate a 60-degree external thread with printable crest/root flats."""
    phase = (theta / (2.0 * math.pi) - z_rel / pitch) % 1.0
    distance_from_crest = min(phase, 1.0 - phase)
    crest_half = CREST_FLAT / 2.0
    root_start = 0.5 - ROOT_FLAT / 2.0

    if distance_from_crest <= crest_half:
        normalized = 1.0
    elif distance_from_crest >= root_start:
        normalized = 0.0
    else:
        normalized = 1.0 - (distance_from_crest - crest_half) / (root_start - crest_half)

    root_radius = root / 2.0
    return root_radius + normalized * (major / 2.0 - root_radius)


def build_thread(
    z0: float,
    z1: float,
    major: float,
    pitch: float,
    cap_start: bool,
    cap_end: bool,
) -> tuple[list[tuple[float, float, float]], list[tuple[float, float, float]]]:
    root = thread_root_diameter(major, pitch)
    length = z1 - z0
    z_steps = max(2, math.ceil(length / pitch * SAMPLES_PER_PITCH))
    rings: list[list[tuple[float, float, float]]] = []

    for i in range(z_steps + 1):
        z = z0 + length * i / z_steps
        z_rel = z - z0
        ring: list[tuple[float, float, float]] = []
        for j in range(SEGMENTS):
            theta = 2.0 * math.pi * j / SEGMENTS
            radius = thread_radius(major, root, pitch, z_rel, theta)
            ring.append((radius * math.cos(theta), radius * math.sin(theta), z))
        rings.append(ring)

    for i in range(z_steps):
        ring = rings[i]
        next_ring = rings[i + 1]
        for j in range(SEGMENTS):
            k = (j + 1) % SEGMENTS
            add_tri(ring[j], ring[k], next_ring[j])
            add_tri(next_ring[j], ring[k], next_ring[k])

    if cap_start:
        center = (0.0, 0.0, z0)
        ring = rings[0]
        for j in range(SEGMENTS):
            add_tri(center, ring[(j + 1) % SEGMENTS], ring[j])

    if cap_end:
        center = (0.0, 0.0, z1)
        ring = rings[-1]
        for j in range(SEGMENTS):
            add_tri(center, ring[j], ring[(j + 1) % SEGMENTS])

    return rings[0], rings[-1]


def hex_radius(theta: float) -> float:
    apothem = HEX_AF / 2.0
    nearest_face = max(math.cos(theta - math.pi / 3.0 * k) for k in range(6))
    return apothem / nearest_face


def hex_ring(z: float) -> list[tuple[float, float, float]]:
    ring: list[tuple[float, float, float]] = []
    for j in range(SEGMENTS):
        theta = 2.0 * math.pi * j / SEGMENTS
        radius = hex_radius(theta)
        ring.append((radius * math.cos(theta), radius * math.sin(theta), z))
    return ring


def build_hex_body(
    z0: float,
    z1: float,
    left_inner: list[tuple[float, float, float]],
    right_inner: list[tuple[float, float, float]],
) -> None:
    outer0 = hex_ring(z0)
    outer1 = hex_ring(z1)

    for j in range(SEGMENTS):
        k = (j + 1) % SEGMENTS

        # Hex side faces.
        add_tri(outer0[j], outer0[k], outer1[j])
        add_tri(outer1[j], outer0[k], outer1[k])

        # Left shoulder face, normal toward -Z.
        add_tri(outer0[j], left_inner[j], outer0[k])
        add_tri(outer0[k], left_inner[j], left_inner[k])

        # Right shoulder face, normal toward +Z.
        add_tri(outer1[j], outer1[k], right_inner[j])
        add_tri(outer1[k], right_inner[k], right_inner[j])


def normal(triangle: Triangle) -> tuple[float, float, float]:
    a, b, c = triangle
    ux, uy, uz = (b[0] - a[0], b[1] - a[1], b[2] - a[2])
    vx, vy, vz = (c[0] - a[0], c[1] - a[1], c[2] - a[2])
    nx = uy * vz - uz * vy
    ny = uz * vx - ux * vz
    nz = ux * vy - uy * vx
    length = math.sqrt(nx * nx + ny * ny + nz * nz)
    if length == 0.0:
        return (0.0, 0.0, 0.0)
    return (nx / length, ny / length, nz / length)


def write_binary_stl(path: Path) -> None:
    header = b"Accu ZTAE38CXM12C-AL style adapter, nominal dimensions in mm"
    with path.open("wb") as stl:
        stl.write(header[:80].ljust(80, b" "))
        stl.write(struct.pack("<I", len(triangles)))
        for triangle in triangles:
            stl.write(struct.pack("<3f", *normal(triangle)))
            for vertex in triangle:
                stl.write(struct.pack("<3f", *vertex))
            stl.write(struct.pack("<H", 0))


def bbox() -> tuple[tuple[float, float, float], tuple[float, float, float]]:
    points = [vertex for triangle in triangles for vertex in triangle]
    mins = tuple(min(point[i] for point in points) for i in range(3))
    maxs = tuple(max(point[i] for point in points) for i in range(3))
    return mins, maxs


def main() -> None:
    total_length = UNC_LENGTH + HEX_LENGTH + M12_LENGTH
    z_min = -total_length / 2.0
    z_hex0 = z_min + UNC_LENGTH
    z_hex1 = z_hex0 + HEX_LENGTH
    z_max = total_length / 2.0

    _, unc_hex_ring = build_thread(
        z_min,
        z_hex0,
        UNC_MAJOR,
        UNC_PITCH,
        cap_start=True,
        cap_end=False,
    )
    m12_hex_ring, _ = build_thread(
        z_hex1,
        z_max,
        M12_MAJOR,
        M12_PITCH,
        cap_start=False,
        cap_end=True,
    )
    build_hex_body(z_hex0, z_hex1, unc_hex_ring, m12_hex_ring)
    write_binary_stl(OUT)

    mins, maxs = bbox()
    print(f"wrote: {OUT}")
    print(f"triangles: {len(triangles)}")
    print(
        "bbox_mm: "
        f"x={mins[0]:.3f}..{maxs[0]:.3f}, "
        f"y={mins[1]:.3f}..{maxs[1]:.3f}, "
        f"z={mins[2]:.3f}..{maxs[2]:.3f}"
    )
    print(f"overall_length_mm: {maxs[2] - mins[2]:.3f}")
    print(f"hex_af_mm: {HEX_AF:.3f}")


if __name__ == "__main__":
    main()
