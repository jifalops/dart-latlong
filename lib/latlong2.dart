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

/// Helps with latitude / longitude calculations.
///
/// For distance calculations the default algorithm [Vincenty] is used.
/// [Vincenty] is a bit slower than [Haversine] but fare more accurate!
///
///      final Distance distance = Distance();
///
///      // km = 423
///      final int km = distance.as(LengthUnit.Kilometer,
///         LatLng(52.518611,13.408056), LatLng(51.519475,7.46694444));
///
///      // meter = 422592
///      final int meter = distance(LatLng(52.518611,13.408056), LatLng(51.519475,7.46694444));
///
/// Find more infos on [Movable Type Scripts](http://www.movable-type.co.uk/scripts/latlong2.html)
/// and [Movable Type Scripts - Vincenty](http://www.movable-type.co.uk/scripts/latlong2-vincenty.html)
///
/// ![latlong2](http://eogn.com/images/newsletter/2014/Latitude-and-longitude.png)
///
/// ![Map](http://www.isobudgets.com/wp-content/uploads/2014/03/latitude-longitude.jpg)
///
library;

import 'dart:math';

export 'src/latlong2/calculator/haversine.dart';
export 'src/latlong2/calculator/vincenty.dart';
export 'src/latlong2/circle.dart';
export 'src/latlong2/distance.dart';
export 'src/latlong2/interfaces.dart';
export 'src/latlong2/lat_lng.dart';
export 'src/latlong2/length_unit.dart';
export 'src/latlong2/path.dart';

/// 2*[pi] as a standalone constant since we are using it rather often
const double twoPi = 2 * pi;

/// The same as [twoPi] (i.e., 2*[pi])
const double tau = twoPi;

/// Equator radius in meter (WGS84 ellipsoid)
const double equatorRadius = 6378137.0;

/// Polar radius in meter (WGS84 ellipsoid)
const double polarRadius = 6356752.314245;

/// WGS84
const double flattening = 1 / 298.257223563;

/// Earth radius in meter
const double earthRadius = equatorRadius;

/// Converts degree to radian
double degToRadian(final double deg) => deg * (pi / 180.0);

/// Radian to degree
double radianToDeg(final double rad) => rad * (180.0 / pi);

/// Rounds [value] to given number of [decimals]
double round(final double value, {final int decimals = 6}) =>
    (value * pow(10, decimals)).round() / pow(10, decimals);

/// Convert a bearing to be within the [0, +360) degrees range.
/// Compass bearing is in the range 0° ... 360°
double normalizeBearing(final double bearing) => (bearing + 360) % 360;

/// Converts a decimal coordinate value to sexagesimal format
///
///     final String sexa1 = decimal2sexagesimal(51.519475);
///     expect(sexa1, '51° 31\' 10.11"');
///
///     final String sexa2 = decimal2sexagesimal(-42.883891);
///     expect(sexa2, '42° 53\' 02.01"');
///
String decimal2sexagesimal(final double dec) {
  final buf = StringBuffer();

  final absDec = dec.abs();
  final deg = absDec.floor();
  buf.write('$deg°');

  final mins = (absDec - deg) * 60.0;
  final min = mins.floor();
  buf.write(" ${zeroPad(min)}'");

  final secs = (mins - mins.floorToDouble()) * 60.0;
  final sec = secs.floor();
  final frac = ((secs - secs.floorToDouble()) * 100.0).round();
  buf.write(' ${zeroPad(sec)}.${zeroPad(frac)}"');

  return buf.toString();
}

/// Converts a string coordinate value in sexagesimal format to decimal
///
///      final dec1 = sexagesimal2decimal('51° 31\' 10.11"');
///      expect(dec1, 51.519475);
///      final dec2 = sexagesimal2decimal('19° 23\' 32.00"');
///      expect(dec2, 19.392222222222223);
///
double sexagesimal2decimal(final String str) {
  final pattern = RegExp('''(\\d+)°\\s*(\\d+)'\\s*(\\d+).(\\d+)"''');
  final m = pattern.firstMatch(str);
  if (m != null) {
    final deg = double.parse(m[1]!);
    final min = double.parse(m[2]!);
    final sec = double.parse(m[3]!);
    final frac = double.parse(m[4]!);
    return deg + min / 60 + sec / (60 * 60) + frac / (60 * 60 * 100);
  } else {
    throw ArgumentError.value(str, 'str', 'Invalid sexagesimal');
  }
}

/// Pads a number with a single zero, if it is less than 10
String zeroPad(num number) => (number < 10 ? '0' : '') + number.toString();
