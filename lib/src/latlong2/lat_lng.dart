/*
 * Copyright (c) 2016, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong2.dart';

/// Coordinates in Degrees
///
///     final LatLng location = LatLng(10.000002, 12.00001);
///
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  double get latitudeInRad => degToRadian(latitude);

  double get longitudeInRad => degToRadian(longitude);

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  LatLng.fromJson(Map<String, dynamic> json)
      : this((json['coordinates'][1] as num).toDouble(),
            (json['coordinates'][0] as num).toDouble());

  Map<String, dynamic> toJson() => {
        'coordinates': [longitude, latitude]
      };

  @override
  String toString() =>
      'LatLng(latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)})';

  /// Converts sexagesimal string into a lat/long value
  ///
  ///     final LatLng p1 = LatLng.fromSexagesimal('''51° 31' 10.11" N, 19° 22' 32.00" W''');
  ///     print("${p1.latitude}, ${p1.longitude}");
  ///     // Shows:
  ///     51.519475, -19.37555556
  ///
  factory LatLng.fromSexagesimal(final String str) {
    double lat = 0.0;
    double lng = 0.0;
    // try format '''47° 09' 53.57" N, 8° 32' 09.04" E'''
    var splits = str.split(',');
    if (splits.length != 2) {
      // try format '''N 47°08'52.57" E 8°32'09.04"'''
      splits = str.split('E');
      if (splits.length != 2) {
        // try format '''N 47°08'52.57" W 8°32'09.04"'''
        splits = str.split('W');
        if (splits.length != 2) {
          throw ArgumentError.value(
              str, 'str', 'Unsupported sexagesimal format');
        }
      }
    }
    lat = sexagesimal2decimal(splits[0]);
    lng = sexagesimal2decimal(splits[1]);
    if (str.contains('S')) {
      lat = -lat;
    }
    if (str.contains('W')) {
      lng = -lng;
    }
    return LatLng(lat, lng);
  }

  /// Converts lat/long values into sexagesimal
  ///
  ///     final LatLng p1 = LatLng(51.519475, -19.37555556);
  ///
  ///     // Shows: 51° 31' 10.11" N, 19° 22' 32.00" W
  ///     print(p1..toSexagesimal());
  ///
  String toSexagesimal() {
    var latDirection = latitude >= 0 ? 'N' : 'S';
    var lonDirection = longitude >= 0 ? 'E' : 'W';
    return '${decimal2sexagesimal(latitude)} $latDirection, ${decimal2sexagesimal(longitude)} $lonDirection';
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  bool operator ==(final Object other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;

  LatLng round({final int decimals = 6}) => LatLng(
      _round(latitude, decimals: decimals),
      _round(longitude, decimals: decimals));

  //- private -----------------------------------------------------------------------------------

  /// No qualifier for top level functions in Dart. Had to copy this function
  double _round(final double value, {final int decimals = 6}) =>
      (value * pow(10, decimals)).round() / pow(10, decimals);
}
