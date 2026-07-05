import 'dart:math' as math;

import '../models/catalog_entry.dart';

/// Similitud coseno (0–1) para vectores L2-normalizados (como InsightFace `normed_embedding`).
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final n = a.length < b.length ? a.length : b.length;
  if (n == 0) return 0;
  double dot = 0;
  double na = 0;
  double nb = 0;
  for (var i = 0; i < n; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  final denom = math.sqrt(na) * math.sqrt(nb);
  if (denom == 0) return 0;
  final s = dot / denom;
  return s.clamp(-1.0, 1.0);
}

CatalogMatch? bestCatalogMatch(
  List<double> query,
  List<CatalogEntry> rows,
  double threshold,
) {
  if (rows.isEmpty) return null;
  CatalogEntry? best;
  var bestScore = -1.0;
  for (final row in rows) {
    final s = cosineSimilarity(query, row.embedding);
    if (s > bestScore) {
      bestScore = s;
      best = row;
    }
  }
  if (best == null || bestScore < threshold) return null;
  return CatalogMatch(entry: best, score: bestScore);
}

class CatalogMatch {
  CatalogMatch({required this.entry, required this.score});

  final CatalogEntry entry;
  final double score;
}
