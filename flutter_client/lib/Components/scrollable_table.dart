import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class ScrollableTable extends StatefulWidget {
  const ScrollableTable({
    super.key,
    required int columnsCount,
    required int rowsCount,
    required TableViewCell Function(BuildContext, TableVicinity) buildCell,
    required Span? Function(int) buildColumnSpan,
    required Span? Function(int) buildRowSpan,
  })  : _columnsCount = columnsCount,
        _rowsCount = rowsCount,
        _buildCell = buildCell,
        _buildColumnSpan = buildColumnSpan,
        _buildRowSpan = buildRowSpan;

  final int _columnsCount;
  final int _rowsCount;
  final TableViewCell Function(BuildContext, TableVicinity) _buildCell;
  final Span? Function(int) _buildColumnSpan;
  final Span? Function(int) _buildRowSpan;

  @override
  State<ScrollableTable> createState() => _ScrollableTableState();
}

class _ScrollableTableState extends State<ScrollableTable> {
  late final ScrollController _verticalController = ScrollController();

  @override
  Widget build(BuildContext context) => TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
        cellBuilder: widget._buildCell,
        columnCount: widget._columnsCount,
        columnBuilder: widget._buildColumnSpan,
        rowCount: widget._rowsCount,
        rowBuilder: widget._buildRowSpan,
      );

  // TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
  //   return TableViewCell(
  //     child: Center(
  //       child: Text('Tile c: ${vicinity.column}, r: ${vicinity.row}'),
  //     ),
  //   );
  // }

  // TableSpan _buildColumnSpan(int index) {
  //   const TableSpanDecoration decoration = TableSpanDecoration(
  //     border: TableSpanBorder(
  //       trailing: BorderSide(),
  //     ),
  //   );

  //   switch (index % 5) {
  //     case 0:
  //       return TableSpan(
  //         foregroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(100),
  //         onEnter: (_) => print('Entered column $index'),
  //         recognizerFactories: <Type, GestureRecognizerFactory>{
  //           TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
  //             () => TapGestureRecognizer(),
  //             (TapGestureRecognizer t) => t.onTap = () => print('Tap column $index'),
  //           ),
  //         },
  //       );
  //     case 1:
  //       return TableSpan(
  //         foregroundDecoration: decoration,
  //         extent: const FractionalTableSpanExtent(0.5),
  //         onEnter: (_) => print('Entered column $index'),
  //         cursor: SystemMouseCursors.contextMenu,
  //       );
  //     case 2:
  //       return TableSpan(
  //         foregroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(120),
  //         onEnter: (_) => print('Entered column $index'),
  //       );
  //     case 3:
  //       return TableSpan(
  //         foregroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(145),
  //         onEnter: (_) => print('Entered column $index'),
  //       );
  //     case 4:
  //       return TableSpan(
  //         foregroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(200),
  //         onEnter: (_) => print('Entered column $index'),
  //       );
  //   }
  //   throw AssertionError('This should be unreachable, as every index is accounted for in the switch clauses.');
  // }

  // TableSpan _buildRowSpan(int index) {
  //   final TableSpanDecoration decoration = TableSpanDecoration(
  //     color: index.isEven ? Colors.purple[100] : null,
  //     border: const TableSpanBorder(
  //       trailing: BorderSide(
  //         width: 3,
  //       ),
  //     ),
  //   );

  //   switch (index % 3) {
  //     case 0:
  //       return TableSpan(
  //         backgroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(50),
  //         recognizerFactories: <Type, GestureRecognizerFactory>{
  //           TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
  //             () => TapGestureRecognizer(),
  //             (TapGestureRecognizer t) => t.onTap = () => print('Tap row $index'),
  //           ),
  //         },
  //       );
  //     case 1:
  //       return TableSpan(
  //         backgroundDecoration: decoration,
  //         extent: const FixedTableSpanExtent(65),
  //         cursor: SystemMouseCursors.click,
  //       );
  //     case 2:
  //       return TableSpan(
  //         backgroundDecoration: decoration,
  //         extent: const FractionalTableSpanExtent(0.15),
  //       );
  //   }
  //   throw AssertionError('This should be unreachable, as every index is accounted for in the switch clauses.');
  // }
}
