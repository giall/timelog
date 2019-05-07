import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:timelog/model.dart';
import 'package:timelog/util.dart';

void main() => runApp(App());

var _c1 = Colors.cyan[600];
var _c2 = Colors.deepOrange[600];
var _ts = TextStyle(fontFamily: 'Lato');

class App extends StatelessWidget {
  @override
  Widget build(_) => MaterialApp(home: Home());
}

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  var logs = []; var map = {};
  var f; var init = false;

  final _tc1 = TextEditingController();
  final _tc2 = TextEditingController();

  @override
  Widget build(_) => FutureBuilder(future: file,
    builder: (_, s) {
      _setup(s);
      var data = map.values.toList();
      var series = [charts.Series(
        id: 'c', data: data, labelAccessorFn: (x, _) => x.name.split(' ').join('\n'),
        domainFn: (x, _) => x.name, measureFn: (x, _) => x.len, colorFn: (x, _) => _color(x.color)
      )];
      var text = Text('Tap on the button below to log an activity!');
      var p = EdgeInsets.all(8.0);
      return DefaultTabController(length: 2,
        child: Scaffold(appBar: AppBar(title: Text('Timelog', style: _ts), backgroundColor: _c1,
          bottom: TabBar(labelStyle: _ts, indicatorColor: Colors.white, tabs: [
            tab(Icons.format_list_bulleted, 'JOURNAL'),
            tab(Icons.pie_chart, 'SUMMARY')
          ])),
          body: TabBarView(children: [
            Center(child: (logs.length > 0) ?  list(p, logs.length, (_, i) => log(logs.reversed.toList()[i])) : text),
            (logs.length > 0) ? Column(children: [
            Expanded(child: Padding(padding: EdgeInsets.only(top: 16.0),
              child: charts.PieChart(series, defaultRenderer: charts.ArcRendererConfig(arcWidth: 60,
              arcRendererDecorators: [charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.outside)]
            )))),
            Expanded(child: Padding(padding: p, child: Card(child: list(p, data.length, (_, i) => sum(data[i])))))])
              : Center(child: text)
        ]),
        floatingActionButton: FloatingActionButton(child: Icon(Icons.edit), backgroundColor: _c2, onPressed: _dialog)
      ));
  });

  btn(txt, fn) => FlatButton(child: Text(txt), onPressed: fn, textColor: _c1);

  tab(icon, txt) => Tab(icon: Icon(icon), text: txt);

  list(p, len, fn) => ListView.separated(
    separatorBuilder: (_, i) => Divider(), padding: p, itemCount: len, itemBuilder: fn
  );

  ListTile log(x) => ListTile(
    title: Text(x.name), subtitle: Text('${x.len} minutes'),
    trailing: Text(x.date, style: TextStyle(color: Colors.grey[600]))
  );

  ListTile sum(x) => ListTile(
    leading: Icon(Icons.fiber_manual_record, color: x.color), title: Text(x.name),
    trailing: Text('${x.len} mins')
  );

  void _dialog() {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Log Activity'),
      content: SingleChildScrollView(child: Column(children: [
        TextField(decoration: InputDecoration(labelText: 'Activity'), controller: _tc1),
        TextField(decoration: InputDecoration(labelText: 'Minutes'), controller: _tc2,
          keyboardType: TextInputType.number)
      ])),
      actions: [btn('CANCEL', () => Navigator.of(context).pop()), btn('SAVE', _log)]
    ));
  }

  void _log() {
    setState(() {
      var string = _tc1.text.toLowerCase();
      var name = string[0].toUpperCase() + string.substring(1);
      var len = int.parse(_tc2.text);
      var date = new DateFormat('d MMM').format(DateTime.now()).toString();
      logs.add(Log(name, len, date)); _add(name, len);
      if (f.length > 0) f += ','; f += '$name:$len:$date';
      write(f);
      _tc1.clear(); _tc2.clear();
    });
    Navigator.of(context).pop();
  }

  void _setup(s) {
    if (!init && s.data != null) {
      f = ''; init = true;
      if (s.data.existsSync()) {
        f = s.data.readAsStringSync();
        logs = f.split(',').map((log) {
          var arr = log.split(':');
          var elem = Log(arr[0], int.parse(arr[1]), arr[2]);
          _add(elem.name, elem.len);
          return elem;
        }).toList();
      }
    }
  }

  void _add(k, v) {
    if (map[k] != null) map[k].len += v;
    else map[k] = Sum(k, v);
  }

  _color(c) => charts.Color(r: c.red, g: c.green, b: c.blue);
}