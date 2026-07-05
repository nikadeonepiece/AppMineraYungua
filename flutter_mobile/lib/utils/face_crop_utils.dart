import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _defaultLeftPadFactor = 0.21;
const double _defaultRightPadFactor = 0.21;
const double _defaultTopPadFactor = 0.55;
const double _defaultBottomPadFactor = 0.28;
const double _defaultSquareScale = 1.06;
const double _defaultHorizontalCenterShiftFactor = 0.0;

/// Expande el rectángulo de ML Kit (suele ceñirse a piel) para incluir frente,
/// mentón y contexto lateral, y centra un recorte cuadrado para modelos tipo MobileFaceNet.
Rect expandFaceRectForEmbedding(
  Rect box,
  int imageWidth,
  int imageHeight, {
  double leftPadFactor = _defaultLeftPadFactor,
  double rightPadFactor = _defaultRightPadFactor,
  double topPadFactor = _defaultTopPadFactor,
  double bottomPadFactor = _defaultBottomPadFactor,
  double squareScale = _defaultSquareScale,
  double horizontalCenterShiftFactor = _defaultHorizontalCenterShiftFactor,
}) {
  final w = box.width;
  final h = box.height;
  if (w <= 0 || h <= 0) return box;

  var left = box.left - w * leftPadFactor;
  var top = box.top - h * topPadFactor;
  var right = box.right + w * rightPadFactor;
  var bottom = box.bottom + h * bottomPadFactor;

  final iw = imageWidth.toDouble();
  final ih = imageHeight.toDouble();

  left = left.clamp(0.0, iw);
  top = top.clamp(0.0, ih);
  right = right.clamp(0.0, iw);
  bottom = bottom.clamp(0.0, ih);

  if (right <= left || bottom <= top) return box;

  var rect = Rect.fromLTRB(left, top, right, bottom);

  // El recuadro final debe quedar centrado en el rostro detectado, no en la
  // expansión asimétrica usada para calcular el tamaño del ROI.
  final cx = box.center.dx + (w * horizontalCenterShiftFactor);
  final cy = box.center.dy;
  var side = math.max(rect.width, rect.height) * squareScale;
  left = cx - side / 2;
  top = cy - side / 2;
  right = cx + side / 2;
  bottom = cy + side / 2;

  if (left < 0) {
    right -= left;
    left = 0;
  }
  if (top < 0) {
    bottom -= top;
    top = 0;
  }
  if (right > iw) {
    final d = right - iw;
    left -= d;
    right = iw;
  }
  if (bottom > ih) {
    final d = bottom - ih;
    top -= d;
    bottom = ih;
  }

  left = left.clamp(0.0, iw);
  top = top.clamp(0.0, ih);
  right = right.clamp(0.0, iw);
  bottom = bottom.clamp(0.0, ih);

  if (right <= left || bottom <= top) return box;
  return Rect.fromLTRB(left, top, right, bottom);
}
