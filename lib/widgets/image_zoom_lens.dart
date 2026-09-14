// ============================================================================
// ImageZoomLens - تأثير العدسة المكبرة على صورة المنتج (Hover Zoom)
// ============================================================================
//
// - بيشتغل بالـ hover على الديسكتوب/الويب بس (مش بيلمس اللمس/السحب على
//   الموبايل)، عشان ميضربش في PageView بتاع معرض صور المنتج (السحب بين
//   الصور بيفضل شغال عادي زي ما هو).
// - بياخد أي ImageProvider (NetworkImage / AssetImage / ...) فبيشتغل مع
//   صور المنتجات اللي جايه من السيرفر عادي.
//
// الاستخدام:
//
//   ImageZoomLens(
//     imageProvider: NetworkImage(url),
//     fit: BoxFit.contain,
//     errorBuilder: (context, error, stack) => ...,
//   )
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageZoomLens extends StatefulWidget {
  /// مصدر الصورة (NetworkImage, AssetImage, FileImage...)
  final ImageProvider imageProvider;

  /// طريقة عرض الصورة الأساسية جوه الفريم
  final BoxFit fit;

  /// قطر دائرة العدسة المكبرة بالبكسل
  final double lensSize;

  /// درجة التكبير
  final double zoomFactor;

  /// شكل العدسة: دائرية ولا مربعة
  final bool circularLens;

  /// تفعيل/تعطيل التأثير (مفيد لو عايز توقفه على الموبايل مثلًا)
  final bool enabled;

  /// بديل الصورة لو فشل التحميل (زي errorBuilder بتاع Image.network)
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ImageZoomLens({
    super.key,
    required this.imageProvider,
    this.fit = BoxFit.contain,
    this.lensSize = 210,
    this.zoomFactor = 2.5,
    this.circularLens = true,
    this.enabled = true,
    this.errorBuilder,
  });

  @override
  State<ImageZoomLens> createState() => _ImageZoomLensState();
}

class _ImageZoomLensState extends State<ImageZoomLens> {
  Offset? _hoverPosition;

  void _onHover(PointerHoverEvent event, Size boxSize) {
    setState(() => _hoverPosition = event.localPosition);
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _hoverPosition = null);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          opaque: false,
          onHover: widget.enabled ? (e) => _onHover(e, boxSize) : null,
          onExit: widget.enabled ? _onExit : null,
          cursor: MouseCursor.defer,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              // الصورة الأساسية - نفس السلوك الأصلي (بدون قص)
              Image(
                image: widget.imageProvider,
                fit: widget.fit,
                errorBuilder: widget.errorBuilder,
              ),

              // دائرة العدسة المكبرة (بتظهر بالـ hover بس)
              if (widget.enabled && _hoverPosition != null && boxSize.width > 0)
                _buildLens(boxSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLens(Size boxSize) {
    final pos = _hoverPosition!;
    final lensRadius = widget.lensSize / 2;

    double lensX = (pos.dx - lensRadius).clamp(0.0, boxSize.width - widget.lensSize);
    double lensY = (pos.dy - lensRadius).clamp(0.0, boxSize.height - widget.lensSize);

    final dx = pos.dx / boxSize.width;
    final dy = pos.dy / boxSize.height;

    final zoomedWidth = boxSize.width * widget.zoomFactor;
    final zoomedHeight = boxSize.height * widget.zoomFactor;

    double offsetX = -(dx * zoomedWidth - lensRadius);
    double offsetY = -(dy * zoomedHeight - lensRadius);

    offsetX = offsetX.clamp(-(zoomedWidth - widget.lensSize), 0.0);
    offsetY = offsetY.clamp(-(zoomedHeight - widget.lensSize), 0.0);

    return Positioned(
      left: lensX,
      top: lensY,
      child: IgnorePointer(
        child: Container(
          width: widget.lensSize,
          height: widget.lensSize,
          decoration: BoxDecoration(
            shape: widget.circularLens ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circularLens ? null : BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.circularLens
                ? BorderRadius.circular(widget.lensSize / 2)
                : BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                OverflowBox(
                  maxWidth: zoomedWidth,
                  maxHeight: zoomedHeight,
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(offsetX, offsetY),
                    child: Image(
                      image: widget.imageProvider,
                      width: zoomedWidth,
                      height: zoomedHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // ظل داخلي (vignette) على حواف العدسة من جوّه - بيدّي
                // إحساس تجويف/عمق زجاجي بدل ما تبان مسطّحة.
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: widget.circularLens ? BoxShape.circle : BoxShape.rectangle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.14),
                        Colors.black.withOpacity(0.28),
                      ],
                      stops: const [0.0, 0.55, 0.72, 0.88, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
