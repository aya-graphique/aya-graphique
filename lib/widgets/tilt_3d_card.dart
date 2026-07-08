import 'package:flutter/material.dart';

/// Wraps any child in a perspective-tilting card: on desktop, it tracks the
/// pointer position and rotates in 3D toward it (like tilting a printed
/// card in your hands), with a lift, scale and a soft moving highlight.
/// On touch devices it falls back to a gentle tap-scale.
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDegrees;
  final double liftOnHover;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTiltDegrees = 10,
    this.liftOnHover = 10,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.onTap,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard>
    with SingleTickerProviderStateMixin {
  Offset _pointer = Offset.zero; // -1..1 in both axes
  bool _hovering = false;
  late final AnimationController _settleController;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event, BoxConstraints constraints) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    final dx = (local.dx / box.size.width) * 2 - 1;
    final dy = (local.dy / box.size.height) * 2 - 1;
    setState(() {
      _pointer = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rotY = _hovering
            ? (_pointer.dx) * (widget.maxTiltDegrees * 3.1415926535 / 180)
            : 0.0;
        final rotX = _hovering
            ? (-_pointer.dy) * (widget.maxTiltDegrees * 3.1415926535 / 180)
            : 0.0;

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // perspective
          ..rotateX(rotX)
          ..rotateY(rotY)
          ..scale(_hovering ? 1.035 : 1.0);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() {
            _hovering = false;
            _pointer = Offset.zero;
          }),
          onHover: (e) => _onHover(e, constraints),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: matrix,
              transformAlignment: Alignment.center,
              margin: EdgeInsets.only(top: _hovering ? 0 : widget.liftOnHover),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hovering ? 0.45 : 0.25),
                      blurRadius: _hovering ? 36 : 18,
                      offset: Offset(0, _hovering ? 22 : 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF9B3FD1)
                          .withOpacity(_hovering ? 0.35 : 0.0),
                      blurRadius: _hovering ? 46 : 0,
                      spreadRadius: _hovering ? 1 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
