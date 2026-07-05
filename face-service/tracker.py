from dataclasses import dataclass


@dataclass
class Track:
    track_id: int
    bbox: tuple[int, int, int, int]
    hits: int = 0
    age: int = 0
    missed: int = 0
    last_detection_index: int | None = None


def iou(a: tuple[int, int, int, int], b: tuple[int, int, int, int]) -> float:
    ax1, ay1, ax2, ay2 = a
    bx1, by1, bx2, by2 = b

    inter_x1 = max(ax1, bx1)
    inter_y1 = max(ay1, by1)
    inter_x2 = min(ax2, bx2)
    inter_y2 = min(ay2, by2)

    inter_w = max(0, inter_x2 - inter_x1)
    inter_h = max(0, inter_y2 - inter_y1)
    inter_area = inter_w * inter_h
    if inter_area <= 0:
        return 0.0

    area_a = max(1, (ax2 - ax1) * (ay2 - ay1))
    area_b = max(1, (bx2 - bx1) * (by2 - by1))
    union = area_a + area_b - inter_area
    return inter_area / max(1.0, union)


class SortLikeTracker:
    """
    Tracker ligero inspirado en SORT:
    - Asigna detecciones a tracks por IoU.
    - Mantiene IDs persistentes mientras haya solape razonable.
    """

    def __init__(self, iou_threshold: float = 0.30, max_missed: int = 10, min_hits: int = 1):
        self.iou_threshold = iou_threshold
        self.max_missed = max_missed
        self.min_hits = min_hits
        self._next_id = 1
        self.tracks: list[Track] = []

    def _best_match(self, bbox: tuple[int, int, int, int], used_track_ids: set[int]) -> Track | None:
        best_track = None
        best_iou = 0.0
        for track in self.tracks:
            if track.track_id in used_track_ids:
                continue
            overlap = iou(track.bbox, bbox)
            if overlap > best_iou:
                best_iou = overlap
                best_track = track
        if best_track is None or best_iou < self.iou_threshold:
            return None
        return best_track

    def update(self, detections: list[tuple[int, int, int, int]]) -> list[Track]:
        used_track_ids: set[int] = set()
        assigned_track_ids: set[int] = set()

        for det_idx, bbox in enumerate(detections):
            matched = self._best_match(bbox, used_track_ids)
            if matched is not None:
                matched.bbox = bbox
                matched.hits += 1
                matched.age += 1
                matched.missed = 0
                matched.last_detection_index = det_idx
                used_track_ids.add(matched.track_id)
                assigned_track_ids.add(matched.track_id)
                continue

            new_track = Track(
                track_id=self._next_id,
                bbox=bbox,
                hits=1,
                age=1,
                missed=0,
                last_detection_index=det_idx,
            )
            self._next_id += 1
            self.tracks.append(new_track)
            used_track_ids.add(new_track.track_id)
            assigned_track_ids.add(new_track.track_id)

        for track in self.tracks:
            if track.track_id not in assigned_track_ids:
                track.missed += 1
                track.age += 1
                track.last_detection_index = None

        self.tracks = [t for t in self.tracks if t.missed <= self.max_missed]
        return [t for t in self.tracks if t.hits >= self.min_hits]

    def active_tracks(self) -> list[Track]:
        return [t for t in self.tracks if t.hits >= self.min_hits]
