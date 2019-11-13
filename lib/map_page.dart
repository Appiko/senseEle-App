import 'package:ele_deploy/locators.dart';
import 'package:ele_deploy/services/hasura_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class Point {
  final LatLng loc;
  final bool alive;
  final int number;

  Point(this.loc, this.alive, this.number);
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  Map points;

  List p;

  List<Point> q;
  MapController mapController;
  var bounds = LatLngBounds();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  _MapPageState() {
    getPoints();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    print("Moving to $destLocation");
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  getPoints() async {
    points = await locator<HasuraService>().query("""
  query {
   node {
     location
     alive
     number
   } 
  }

  
  """);
    // print(points['data']['node']);
    p = points['data']['node'];

    setState(() {
      q = p.map((p) {
        List x = p['location']
            .toString()
            .replaceAll("(", "")
            .replaceAll(")", "")
            .split(",");
        print(x);
        double lat = double.tryParse(x[0]);
        double lng = double.tryParse(x[1]);
        var latLng = LatLng(lat, lng);
        bounds.extend(latLng);
        return Point(latLng, p['alive'], p['number']);
      }).toList();
      if (q.length > 0) {
        mapController.fitBounds(
          bounds,
          options: FitBoundsOptions(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),
        );
        _animatedMapMove(q[0].loc, 16);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // getPoints();
    return new FlutterMap(
      mapController: mapController,
      options: MapOptions(
        zoom: 16,
        center: LatLng(12, 77),
        maxZoom: 19.4,
        minZoom: 10,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "http://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
          // urlTemplate:
          //     "https://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?",
          additionalOptions: {
            'maxZoom': '20',
            'attribution':
                '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          },
        ),
        MarkerLayerOptions(
          markers: q != null
              ? List.generate(q.length, (index) {
                  return Marker(
                    width: 43,
                    height: 66,
                    point: q[index].loc,
                    builder: (ctx) => InkWell(
                      onTap: () {
                        _animatedMapMove(q[index].loc, mapController.zoom);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  q[index].number.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.yellow,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset.fromDirection(0, 5),
                                        color: Colors.black54)
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              // color: Colors.red,
                              height: 14,
                              width: 14,
                              child: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CircleAvatar(
                                      backgroundColor: q[index].alive ?? false
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
              : [
                  Marker(
                    width: 5.0,
                    height: 5.0,
                    point: LatLng(0, 0),
                    builder: (ctx) => new Container(
                      child: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
        )
      ],
    );
  }
}
