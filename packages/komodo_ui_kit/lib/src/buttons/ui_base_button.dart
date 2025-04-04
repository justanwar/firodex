import 'package:flutter/cupertino.dart';

class UIBaseButton extends StatelessWidget {
  const UIBaseButton({
    required this.isEnabled,
    required this.child,
    this.width,
    this.height,
    required this.border,
    super.key,
  });
  final bool isEnabled;
  final double? width;
  final double? height;
  final BoxBorder? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.4,
        child: Container(
          constraints: _buildConstraints(),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }

  BoxConstraints _buildConstraints() {
    if (width != null && height != null) {
      return BoxConstraints.tightFor(width: width, height: height);
    } else if (width != null) {
      return BoxConstraints.tightFor(width: width);
    } else if (height != null) {
      return BoxConstraints.tightFor(height: height);
    } else {
      return const BoxConstraints();
    }
  }
}
