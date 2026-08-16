import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Rasterises a widget that is never on screen.
///
/// A home-screen widget is drawn by the launcher, not by Flutter, and
/// `RemoteViews` has no chart primitive — so the only way to put Jatra's own
/// typography and charts on a home screen is to hand Android a finished
/// bitmap. This builds a private render tree, drives one frame of it by hand,
/// and reads the result back as a PNG.
///
/// Nothing here touches the live app's tree, so it is safe to call while the
/// user is mid-screen, and it works with the app in the background where a
/// `RepaintBoundary` hidden inside the real tree would not.
abstract final class OffscreenRenderer {
  /// Renders [child] at [size] logical pixels and [pixelRatio] device pixels
  /// per logical pixel.
  ///
  /// Returns null when there is no view to borrow a rasteriser from, which
  /// is the case on a headless isolate — callers treat that as "skip this
  /// update" rather than an error.
  static Future<Uint8List?> toPng({
    required Widget child,
    required Size size,
    required double pixelRatio,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return null;

    final boundary = RenderRepaintBoundary();

    // The boundary is the view's only child, under constraints tight at
    // exactly [size]: the face is laid out to fill the host widget, and any
    // slack would show up as a transparent margin on the home screen.
    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(size),
        physicalConstraints: BoxConstraints.tight(size * pixelRatio),
        devicePixelRatio: pixelRatio,
      ),
      child: boundary,
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RootWidget(
      debugShortDescription: 'Jatra home-screen widget',
      child: _Adopt(
        boundary: boundary,
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: pixelRatio,
            // The widget's layout is tuned to a fixed dp box that the
            // launcher chose; honouring the system font scale on top of that
            // would push tiles out of their own bitmap. Type already scales
            // with the widget's size instead — see `WidgetFace._scale`.
            textScaler: TextScaler.noScaling,
          ),
          child: Directionality(textDirection: textDirection, child: child),
        ),
      ),
    ).attach(buildOwner);

    ui.Image? image;
    try {
      buildOwner
        ..buildScope(rootElement)
        ..finalizeTree();
      pipelineOwner
        ..flushLayout()
        ..flushCompositingBits()
        ..flushPaint();

      image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image?.dispose();

      // Tear down in the reverse of the order it was built, or the asserts
      // that guard each layer fire in turn:
      //
      //  * the render tree comes apart first, because deactivating a
      //    `RenderObjectElement` requires its render object to be detached —
      //    and this one's parent was wired up by hand, so no ancestor
      //    element will detach it for us;
      //  * then the element tree, by rebuilding the root with no child at
      //    all: that deactivates the subtree, and `finalizeTree` unmounts
      //    and disposes it. Skipping this leaks a little on every write to
      //    the log, which is often;
      //  * then the owners, each of which refuses to be disposed while it
      //    still holds a root.
      try {
        renderView.child = null;
        const RootWidget().attach(buildOwner, rootElement);
        buildOwner
          ..buildScope(rootElement)
          ..finalizeTree();
        pipelineOwner.rootNode = null;
      } catch (error, stack) {
        // Never let cleanup mask a successful render — the bitmap is
        // already in hand by this point.
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'jatra',
            context: ErrorDescription('tearing down the off-screen widget'),
          ),
        );
      }
      renderView.dispose();
      pipelineOwner.dispose();
    }
  }
}

/// Splices a pre-built [RenderRepaintBoundary] into the widget tree.
///
/// The render tree above is assembled by hand — it has to be, since
/// [RenderView] needs its child before a frame can be prepared — while the
/// content below is ordinary widgets. This is the seam between the two: it
/// hands back the boundary that is *already* the render tree's child instead
/// of creating one.
///
/// It has to be a [RenderTreeRootElement] to do that. A plain
/// [RenderObjectElement] insists on finding an ancestor element to attach its
/// render object to and asserts when it cannot — which is exactly our case,
/// since the boundary's parent was wired up in [OffscreenRenderer.toPng]
/// rather than by any element. This is the same mechanism `View` uses to
/// start a render tree of its own; it simply adopts a render object instead
/// of building one.
class _Adopt extends RenderObjectWidget {
  const _Adopt({required this.boundary, required this.child});

  final RenderRepaintBoundary boundary;
  final Widget child;

  @override
  RenderObjectElement createElement() => _AdoptElement(this);

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) => boundary;
}

class _AdoptElement extends RenderTreeRootElement {
  _AdoptElement(_Adopt super.widget);

  Element? _child;

  @override
  RenderRepaintBoundary get renderObject =>
      super.renderObject as RenderRepaintBoundary;

  @override
  void visitChildren(ElementVisitor visitor) {
    final child = _child;
    if (child != null) visitor(child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _rebuild();
  }

  @override
  void update(_Adopt newWidget) {
    super.update(newWidget);
    _rebuild();
  }

  void _rebuild() {
    _child = updateChild(_child, (widget as _Adopt).child, null);
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(
    RenderBox child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    assert(
      false,
      'The off-screen tree has exactly one child and never moves it.',
    );
  }

  @override
  void removeRenderObjectChild(RenderBox child, Object? slot) {
    renderObject.child = null;
  }
}
