import 'package:flutter/material.dart';

class CustomShimmer extends StatefulWidget {
  const CustomShimmer({super.key});

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shimmerGradient = LinearGradient(
      colors: [
        colorScheme.outline,
        colorScheme.outlineVariant,
        colorScheme.outline,
      ],
      stops: const [
        0.1,
        0.3,
        0.4,
      ],
      begin: const Alignment(-2.0, -0.3),
      end: const Alignment(1.0, 0.3),
      tileMode: TileMode.clamp,
    );

    return Shimmer(
      linearGradient: shimmerGradient,
      child: const Column(
        children: [
          BuildPostCard(),
          BuildPostCard(),
          BuildPostCard(),
        ],
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  const Shimmer({
    super.key,
    required this.linearGradient,
    this.child,
  });

  final LinearGradient linearGradient;
  final Widget? child;
  @override
  State<Shimmer> createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
      colors: widget.linearGradient.colors,
      stops: widget.linearGradient.stops,
      begin: widget.linearGradient.begin,
      end: widget.linearGradient.end,
      transform:
          _SlidingGradientTransform(slidePercent: _shimmerController.value));

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset(
      {required RenderBox descendant, Offset offset = Offset.zero}) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final shimmer = Shimmer.of(context);
    if (shimmer == null || !shimmer.isSized) {
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject() as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ======== Card Elements =================

Widget _cardElements({
  required BuildContext context,
  required double width,
  required double height,
  bool isCircle = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: !isCircle ? BorderRadius.circular(20.0) : null,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          color: colorScheme.outline,
        )),
  );
}

class BuildPostCard extends StatefulWidget {
  const BuildPostCard({super.key});

  @override
  State<BuildPostCard> createState() => BuildPostCardState();
}

class BuildPostCardState extends State<BuildPostCard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Container(
          width: double.maxFinite,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: colorScheme.onSurface.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: Row(
                    children: [
                      _cardElements(
                        width: 33,
                        height: 33,
                        isCircle: true,
                        context: context,
                      ),
                      const SizedBox(width: 10),
                      _cardElements(
                        width: 100,
                        height: 15,
                        context: context,
                      ),
                    ],
                  ),
                ),
                _cardElements(
                  width: 170,
                  height: 15,
                  context: context,
                ),
                _cardElements(
                  width: double.maxFinite,
                  height: 15,
                  context: context,
                ),
                // image height
                Expanded(
                  child: _cardElements(
                    context: context,
                    width: double.maxFinite,
                    height: double.maxFinite,
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
