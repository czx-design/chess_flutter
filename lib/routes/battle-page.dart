import 'package:chess_override/routes/setting-page.dart';

import '../cchess/step-name.dart';
import '../common/toast.dart';
import '../engine/analysis.dart';

import '../engine/engine.dart';
import '../engine/native-engine.dart';
import '../services/audios.dart';

import '../cchess/cc-base.dart';
import '../common/color-consts.dart';
import '../engine/cloud-engine.dart';
import '../game/battle.dart';
import '../main.dart';
import '../board/board-widget.dart';
import 'package:flutter/material.dart';

class BattlePage extends StatefulWidget {
  // 棋盘的纵横方向的边距
  static double boardMargin = 10.0, screenPaddingH = 10.0;

  final EngineType engineType;
  final AiEngine engine;

  // 根据场景创建云库引擎或是原生的单机 AI 引擎
  BattlePage(this.engineType)
      : engine =
            engineType == EngineType.Cloud ? CloudEngine() : NativeEngine();

  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  String _status = '';

  bool _analysising = false;

  changeStatus(String status) => setState(() => _status = status);

  void calcScreenPaddingH() {
    // 当屏幕的纵横比小于16/9时，限制棋盘的宽度
    final windowSize = MediaQuery.of(context).size;
    double height = windowSize.height, width = windowSize.width;

    if (height / width < 16.0 / 9.0) {
      width = height * 9 / 16;
      // 横盘宽度之外的空间，分左右两边，由 screenPaddingH 来持有，布局时添加到 BoardWidget 外围水平边距
      BattlePage.screenPaddingH =
          (windowSize.width - width) / 2 - BattlePage.boardMargin;
    }
  }

  // 由 BattlePage 的 State 类来处理棋盘的点击事件
  onBoardTap(BuildContext context, int index) {
    final phase = Battle.shared.phase;

    //仅 Phase 中的 side 指示一方能动棋
    if (phase.side != Side.Red) return;

    final tapedPiece = phase.pieceAt(index);

    // 之前已经有棋子被选中了
    if (Battle.shared.focusIndex != Move.InvalidIndex &&
        Side.of(phase.pieceAt(Battle.shared.focusIndex)) == Side.Red) {
      // 当前点击的棋子和之前已经选择的是同一个位置
      if (Battle.shared.focusIndex == index) return;

      // 之前已经选择的棋子和现在点击的棋子是同一边的，说明是选择另外一个棋子
      final focusPiece = phase.pieceAt(Battle.shared.focusIndex);

      if (Side.sameSide(focusPiece, tapedPiece)) {
        Battle.shared.select(index);
      } else if (Battle.shared.move(Battle.shared.focusIndex, index)) {
        // 现在点击的棋子和上一次选择棋子不同边，要么是吃子，要么是移动棋子到空白处
        final result = Battle.shared.scanBattleResult();

        switch (result) {
          case BattleResult.Pending:
            // 玩家走一步棋后，如果游戏还没有结束，则启动引擎走棋
            engineToGo();
            break;
          case BattleResult.Win:
            gotWin();
            break;
          case BattleResult.Lose:
            gotLose();
            break;
          case BattleResult.Draw:
            gotDraw();
            break;
        }
      }
    } else {
      // 之前未选择棋子，现在点击就是选择棋子
      if (tapedPiece != Piece.Empty) Battle.shared.select(index);
    }
    setState(() {});
  }

  //显示胜利框
  void gotWin() {
    Audios.playTone('win.mp3');
    Battle.shared.phase.result = BattleResult.Win;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '赢了',
              style: TextStyle(color: ColorConsts.Primary),
            ),
            content: Text('恭喜您取得了伟大的胜利！'),
            actions: <Widget>[
              FlatButton(onPressed: newGame, child: Text('再来一局')),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('关闭')),
            ],
          );
        });
  }

  // 显示失败框
  void gotLose() {
    Audios.playTone('lose.mp3');

    Battle.shared.phase.result = BattleResult.Lose;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('输了', style: TextStyle(color: ColorConsts.Primary)),
          content: Text('勇士！坚定战斗，虽败犹荣！'),
          actions: <Widget>[
            FlatButton(child: Text('再来一盘'), onPressed: newGame),
            FlatButton(
                child: Text('关闭'),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  //显示和棋框
  void gotDraw() {
    Battle.shared.phase.result = BattleResult.Draw;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '和了',
              style: TextStyle(color: ColorConsts.Primary),
            ),
            content: Text('您用自己的力量捍卫了和平！'),
            actions: <Widget>[
              FlatButton(onPressed: newGame, child: Text('再来一局')),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('关闭')),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // 使用默认的「新对局」棋子分布
    Battle.shared.init();
    //启动引擎
    widget.engine.startup();
  }

  @override
  void dispose() {
    // 关闭引擎
    widget.engine.shutdown();
    super.dispose();
  }

  // 标题、活动状态、顶部按钮等
  Widget createPageHeader() {
    final titleStyle =
        TextStyle(fontSize: 28, color: ColorConsts.DarkTextPrimary);
    final subTitleStyle =
        TextStyle(fontSize: 16, color: ColorConsts.DarkTextSecondary);

    return Container(
      margin: EdgeInsets.only(top: ChessRoadApp.StatusBarHeight),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: ColorConsts.DarkTextPrimary,
                  onPressed: () => Navigator.of(context).pop()),
              Expanded(child: SizedBox()),
              //Hero(tag: 'logo', child: Image.asset('images/logo.png')),
              // SizedBox(width: 10),
              Text(widget.engineType == EngineType.Cloud ? '挑战服务器' : '本地对战',
                  style: titleStyle),
              Expanded(child: SizedBox()),
              IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: ColorConsts.DarkTextPrimary,
                  ),
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      ))
            ],
          ),
          Container(
            height: 4,
            width: 180,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: ColorConsts.BoardBackground,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(_status, maxLines: 1, style: subTitleStyle),
          )
        ],
      ),
    );
  }

  Widget createBoard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: BattlePage.screenPaddingH,
        vertical: BattlePage.boardMargin,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConsts.BoardBackground,
      ),
      child: BoardWidget(
        width:
            MediaQuery.of(context).size.width - BattlePage.screenPaddingH * 2,
        onBoardTap: onBoardTap,
      ),
    );
  }

  Widget createOperatorBar() {
    final buttonStyle = TextStyle(color: ColorConsts.Primary, fontSize: 20);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: ColorConsts.BoardBackground,
      ),
      margin: EdgeInsets.symmetric(horizontal: BattlePage.screenPaddingH),
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(children: <Widget>[
        Expanded(child: SizedBox()),
        FlatButton(child: Text('新对局', style: buttonStyle), onPressed: newGame),
        Expanded(child: SizedBox()),
        FlatButton(
          child: Text('悔棋', style: buttonStyle),
          onPressed: () {
            Battle.shared.regret(steps: 2);
            setState(() {});
          },
        ),
        Expanded(child: SizedBox()),
        FlatButton(
          child: Text('分析局面', style: buttonStyle),
          onPressed: _analysising ? null : analysisPhase,
        ),
        Expanded(child: SizedBox()),
      ]),
    );
  }

  Widget buildFooter() {
    final size = MediaQuery.of(context).size;

    final manualText = Battle.shared.phase.manualText;

    if (size.height / size.width > 16 / 9) {
      //长屏幕显示落法列表
      return buildManualPanel(manualText);
    } else {
      // 短屏幕显示一个按钮，点击它后弹出着法列表
      return buildExpandableManaulPanel(manualText);
    }
  }

  // 长屏幕显示着法列表
  Widget buildManualPanel(String text) {
    //
    final manualStyle = TextStyle(
      fontSize: 18,
      color: ColorConsts.DarkTextSecondary,
      height: 1.5,
    );

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(child: Text(text, style: manualStyle)),
      ),
    );
  }

  // 短屏幕显示一个按钮，点击它后弹出着法列表
  Widget buildExpandableManaulPanel(String text) {
    final manualStyle = TextStyle(fontSize: 18, height: 1.5);

    return Expanded(
      child: IconButton(
        icon: Icon(Icons.expand_less, color: ColorConsts.DarkTextPrimary),
        onPressed: () => showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('棋谱', style: TextStyle(color: ColorConsts.Primary)),
              content:
                  SingleChildScrollView(child: Text(text, style: manualStyle)),
              actions: <Widget>[
                FlatButton(
                  child: Text('好的'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  engineToGo() async {
    changeStatus('对方思考ing');

    final response = await widget.engine.search(Battle.shared.phase);

    if (response.type == 'move') {
      final step = response.value;
      Battle.shared.move(step.from, step.to);

      final result = Battle.shared.scanBattleResult();

      switch (result) {
        case BattleResult.Pending:
          changeStatus('请走棋...');
          break;
        case BattleResult.Win:
          gotWin();
          break;
        case BattleResult.Lose:
          gotLose();
          break;
        case BattleResult.Draw:
          gotDraw();
          break;
      }
      //
    } else {
      changeStatus('Error: ${response.type}');
    }
  }

  newGame() {
    //
    confirm() {
      Navigator.of(context).pop();
      Battle.shared.newGame();
      setState(() {});
    }

    cancel() => Navigator.of(context).pop();

    // 开始新方法之前需要用户确认
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('放弃对局？', style: TextStyle(color: ColorConsts.Primary)),
          content: SingleChildScrollView(child: Text('你确定要放弃当前的对局吗？')),
          actions: <Widget>[
            FlatButton(child: Text('确定'), onPressed: confirm),
            FlatButton(child: Text('取消'), onPressed: cancel),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //使用 MediaQuery 查询了窗口的尺寸, 得到了 BoardWidget 的适当宽度
    calcScreenPaddingH();

    final header = createPageHeader();
    final board = createBoard();
    final operatorBar = createOperatorBar();
    final footer = buildFooter();

    return Scaffold(
      backgroundColor: ColorConsts.DarkBackground,
      body: Column(
        children: <Widget>[header, board, operatorBar, footer],
      ),
    );
  }

  analysisPhase() async {
    //
    Toast.toast(context, msg: '正在分析局面...', position: ToastPostion.bottom);

    setState(() => _analysising = true);

    try {
      final result = await CloudEngine.analysis(Battle.shared.phase);

      // 云库反回了正确的分析结果
      if (result.type == 'analysis') {
        //
        List<AnalysisItem> items = result.value;
        items.forEach(
          (item) => item.stepName = StepName.translate(
            Battle.shared.phase,
            Move.fromEngineStep(item.move),
          ),
        );
        showAnalysisItems(
          context,
          title: '推荐招法',
          items: result.value,
          callback: (index) => Navigator.of(context).pop(),
        );
      } else if (result.type == 'no-result') {
        // 云库表示无分析结论
        // 我们提交服务器后台进行计算，玩家可以过一会再点击分析来查看分析结论
        Toast.toast(
          context,
          msg: '已请求服务器计算，请稍后查看！',
          position: ToastPostion.bottom,
        );
      } else {
        Toast.toast(
          context,
          msg: '错误: ${result.type}',
          position: ToastPostion.bottom,
        );
      }
    } catch (e) {
      Toast.toast(context, msg: '错误: $e', position: ToastPostion.bottom);
    } finally {
      setState(() => _analysising = false);
    }
  }

  // 显示分析结论
  showAnalysisItems(
    BuildContext context, {
    String title,
    List<AnalysisItem> items,
    Function(AnalysisItem item) callback,
  }) {
    //
    final List<Widget> children = [];

    for (var item in items) {
      children.add(
        ListTile(
          title: Text(item.stepName, style: TextStyle(fontSize: 18)),
          subtitle: Text('胜率：${item.winrate}%'),
          trailing: Text('分数：${item.score}'),
          onTap: () => callback(item),
        ),
      );
      children.add(Divider());
    }

    children.insert(0, SizedBox(height: 10));
    children.add(SizedBox(height: 56));

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
