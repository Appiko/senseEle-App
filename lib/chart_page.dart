import 'package:charts_flutter/flutter.dart';
import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:flutter/widgets.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  void initState() {
    getChart1();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 100,
        ),
        FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SizedBox(
                  height: 300,
                  child: BarChart(
                    snapshot.data,
                    animationDuration: Duration(milliseconds: 100),
                    animate: true,
                    behaviors: [
                      // Add the sliding viewport behavior to have the viewport center on the
                      // domain that is currently selected.
                      SlidingViewport(),
                      // A pan and zoom behavior helps demonstrate the sliding viewport
                      // behavior by allowing the data visible in the viewport to be adjusted
                      // dynamically.
                      PanAndZoomBehavior(),
                    ],
                  ));
            }
            if (snapshot.hasError) {
              return Text("Error!");
            }
          },
          initialData: ([Series(data: [], domainFn: (_, __) => "loading...")]),
          future: _createSampleData(),
        ),
        Text("Date vs Number of alerts",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<List<Series<NodeAlert, String>>> _createSampleData() async {
    var data = await getChart1();
    return [
      new Series<NodeAlert, String>(
        id: 'Node vs Alerts',
        colorFn: (_, __) => MaterialPalette.red.shadeDefault,
        domainFn: (NodeAlert n, _) => n.date.toString(),
        measureFn: (NodeAlert n, _) => n.alert,
        data: data,
      )
    ];
  }

  Future<List<NodeAlert>> getChart1() async {
    var c1Data = await locator<HasuraService>().query("""
{
  alert {
    time
  }
}
  
  """);
    // print(points['data']['node']);
    var p = c1Data['data']['alert'];
    Map<String, int> map = {};
    List<NodeAlert> data = [];
    p.forEach((alert) {
      var date = alert['time'].toString().substring(0, 10);

      map.containsKey(date) ? map[date] = map[date] + 1 : map[date] = 1;
    });
    map.forEach((d, c) => data.add(NodeAlert(d, c)));
    print(data);
    return data;
  }
}

/// Sample ordinal data type.
class NodeAlert {
  final String date;
  final int alert;

  NodeAlert(this.date, this.alert);

  @override
  String toString() {
    return "{$date, $alert}";
  }
}
