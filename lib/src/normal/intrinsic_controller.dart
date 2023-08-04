part of '../widget.dart';

//Todo: You are doing too risky task when allowing user to change axis and crossAxisCount,
//What if concurrency(Although its Sync), and what about user modifying these value themself.
//Todo: Variable refactor to denote both horizontal and vertical scrolling
class IntrinsicController extends ValueNotifier<bool> {
  IntrinsicController() : super(true);

  int refreshCount=0;
  final _intrinsicHeightCalculator= IntrinsicSizeCalculator();
  var _beenInitializedOnce = false; //Make completer
  Axis _axis = Axis.vertical;
  int _crossAxisCount = 0; //0 means not set yet
  List<Widget> _widgetList = [];

  ///Returns unmodifiable list, so you cannot update it.
  ///If you want to update it, you have to use the setter method
  List<Widget> get widgetList => List.unmodifiable(_widgetList);

  ///On Value updated, widgets get rebuild,
  ///and intrinsic height are recalculated
  set widgetList(List<Widget> newValue) {
    super.value = true;
    super.addListener(() {//Todo: What about removing the listener because in next change too this lister is being called, concurrency
      if (!super.value) {
        _widgetList = newValue;
      }
    });
  }

  //Todo: Make it work, and logic verify
  void _onGridviewConstructed({
    required bool preventRebuild,
    required List<Widget> widgets,
    required Axis axis,
    required int crossAxisCount,
  }) {
    if (!(_beenInitializedOnce && preventRebuild)) {
      _axis = axis;
      _crossAxisCount = crossAxisCount;
      _widgetList=widgets;
      super.value=true;
    }
  }

  //Todo: Currently excluding gap, why??
  double get getSize => _intrinsicMainAxisExtends.fold(
      0, (previousValue, element) => previousValue + element);




  IntrinsicDelegate get intrinsicRowGridDelegate => IntrinsicDelegate(
        crossAxisCount: _crossAxisCount,
        crossAxisIntrinsicSize: _intrinsicMainAxisExtends,
        totalItems: widgetList.length,
        crossAxisSizeRefresh: refreshCount,
      );
  List<double> _intrinsicMainAxisExtends = [];

  /// Have caching, at first when is in initializing phase, do not display gridview.
  /// On second time, even if its initializing, display old gridview
  /// till new gridview data is not loaded.
  bool get canDisplayGridView => _beenInitializedOnce || !super.value;

  Widget renderAndCalculate() {
    print("Was here ${_widgetList.length} ${super.value}");
    if (!super.value) return const SizedBox();
    if(_widgetList.isEmpty || _crossAxisCount<=0){
      return const SizedBox();
    }
    print("Was here too${_widgetList.length}");
    return _intrinsicHeightCalculator.renderAndCalculate(
      CalculatorInput(
          itemList: _widgetList,
          crossAxisItemsCount: _crossAxisCount,
          axis: _axis,
          onSuccess: () async {
            _intrinsicMainAxisExtends =
                _intrinsicHeightCalculator.intrinsicMainAxisExtends;
            _beenInitializedOnce = true;
            refreshCount++;
            super.value=false;
          }),
    );
  }

}
