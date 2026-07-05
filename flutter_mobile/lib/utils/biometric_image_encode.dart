import 'package:image/image.dart' as img;

/// JPEG compacto para [match-from-image]: menos CPU en codificación y menos red.
List<int> encodeBiometricJpegForServer(
  img.Image crop, {
  int maxSide = 480,
  int quality = 76,
}) {
  var im = crop;
  if (crop.width > maxSide || crop.height > maxSide) {
    int nw;
    int nh;
    if (crop.width >= crop.height) {
      nw = maxSide;
      nh = (crop.height * maxSide / crop.width).round().clamp(1, 4096);
    } else {
      nh = maxSide;
      nw = (crop.width * maxSide / crop.height).round().clamp(1, 4096);
    }
    im = img.copyResize(crop, width: nw, height: nh);
  }
  return img.encodeJpg(im, quality: quality);
}
