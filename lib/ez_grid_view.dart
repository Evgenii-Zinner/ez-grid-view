import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware version of [GridView.builder].
///
/// Features:
/// *   **Crash Prevention:** Automatically detects unbounded constraints (e.g., inside [Column] or [Row]) and applies a safe fallback size.
/// *   **Debug Feedback:** In debug mode, displays a red border and logs a detailed error explaining the issue and the fix.
/// *   **Drop-in Replacement:** Supports the same API as [GridView.builder].
class EzGridView extends StatelessWidget {
  /// See [GridView.builder.itemBuilder].
  final IndexedWidgetBuilder itemBuilder;

  /// See [GridView.builder.itemCount].
  final int? itemCount;

  /// See [GridView.builder.physics].
  final ScrollPhysics? physics;

  /// See [GridView.builder.padding].
  final EdgeInsetsGeometry? padding;

  /// See [GridView.builder.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Creates a defensive, self-aware version of [GridView.builder].
  ///
  /// This widget automatically detects unbounded constraints and applies a fix
  /// to prevent layout crashes, providing detailed debugging information in
  /// debug mode.
  const EzGridView.builder({
    super.key,
    required this.itemBuilder,
    required this.gridDelegate,
    this.itemCount,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        // If constraints are fine, just build the GridView.
        if (!isUnboundedHeight && !isUnboundedWidth) {
          return GridView.builder(
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            padding: padding,
            physics: physics,
            gridDelegate: gridDelegate,
          );
        }

        // --- Apply safe fallback for unbounded constraints ---
        Widget fixedGridView = GridView.builder(
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          padding: padding,
          physics: physics,
          gridDelegate: gridDelegate,
        );

        final mediaQuery = MediaQuery.of(context);

        final double fixedHeight;
        if (isUnboundedHeight) {
          // Calculate a reasonable default height based on the screen size.
          final calculatedSafeHeight =
              mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
          fixedHeight = calculatedSafeHeight * 0.5; // Use 50% as a default
        } else {
          fixedHeight = constraints.maxHeight;
        }

        final double fixedWidth;
        if (isUnboundedWidth) {
          fixedWidth = mediaQuery.size.width * 0.5; // Use 50% as a default
        } else {
          fixedWidth = constraints.maxWidth;
        }

        if (kDebugMode) {
          // Identify the parent widget causing the issue and report a detailed error.
          _reportError(context, isUnboundedWidth, isUnboundedHeight);

          // Wrap with a visual indicator to highlight the problematic widget.
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: fixedGridView,
            ),
          );
        }

        // In release mode, apply the fix silently to prevent a crash.
        return SizedBox(
          width: fixedWidth,
          height: fixedHeight,
          child: fixedGridView,
        );
      },
    );
  }

  /// Reports a detailed error about which dimension was unbounded.
  void _reportError(BuildContext context, bool badWidth, bool badHeight) {
    String culprit = "an unknown parent";
    context.visitAncestorElements((element) {
      if (element.widget is Flex ||
          element.widget is ListView ||
          element.widget is CustomScrollView) {
        culprit = element.widget.runtimeType.toString();
        return false;
      }
      return true;
    });

    String problematicDimension = "unknown";
    if (badWidth && badHeight) {
      problematicDimension = "width and height";
    } else if (badWidth) {
      problematicDimension = "width";
    } else {
      problematicDimension = "height";
    }

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: 'EzGridView: Unbounded $problematicDimension detected.',
        library: 'EzGridView',
        context: ErrorDescription('while building EzGridView'),
        informationCollector: () => [
          ErrorSummary('EzGridView has applied an automatic layout fix.'),
          ErrorDescription(
            'This widget was placed directly inside a $culprit, which provides infinite $problematicDimension. '
            'This would normally cause a layout crash.',
          ),
          ErrorHint(
            'ACTION REQUIRED: For a permanent fix, you must wrap EzGridView in a widget that provides bounded constraints, such as an Expanded or a SizedBox.',
          ),
        ],
      ),
    );
  }
}
