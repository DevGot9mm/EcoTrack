part of 'common.dart';

List<Widget> _gapped(List<Widget> items, double gap) {
  if (items.length < 2) return items;
  final List<Widget> out = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    if (i > 0) out.add(SizedBox(width: gap));
    out.add(items[i]);
  }
  return out;
}

/// Horizontal padding used by every screen block.
class HPad extends StatelessWidget {
  const HPad({super.key, required this.child, this.value = 24});

  final Widget child;
  final double value;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: value), child: child);
}

/// Lays items out in fixed-column rows. Every card in a row is stretched to the
/// tallest, which is what the prototype's CSS grid does.
///
/// Cells are given explicit widths rather than `Expanded`, so the intrinsic
/// height pass stays cheap and well-defined. Nothing inside a cell may use a
/// `LayoutBuilder` (so no [EcoBar]) because intrinsic sizing cannot measure it.
class EcoGrid extends StatelessWidget {
  const EcoGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.gap = 12,
  });

  final List<Widget> items;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int cols = columns < 1 ? 1 : columns;
        final double cellW =
            c.maxWidth.isFinite ? (c.maxWidth - gap * (cols - 1)) / cols : 0;

        final List<Widget> rows = <Widget>[];
        for (int i = 0; i < items.length; i += cols) {
          final List<Widget> row = <Widget>[];
          for (int k = 0; k < cols; k++) {
            final int idx = i + k;
            if (k > 0) row.add(SizedBox(width: gap));
            row.add(
              SizedBox(
                width: cellW,
                child:
                    idx < items.length ? items[idx] : const SizedBox.shrink(),
              ),
            );
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: row,
              ),
            ),
          );
          if (i + cols < items.length) rows.add(SizedBox(height: gap));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

