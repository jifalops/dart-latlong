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

import 'package:latlong2/latlong2.dart';

class Haversine implements DistanceCalculator {
  const Haversine();

  /// Calculates distance with Haversine algorithm.
  ///
  /// Accuracy can be out by 0.3%
  /// More on [Wikipedia](https://en.wikipedia.org/wiki/Haversine_formula)
  @override
  double distance(final LatLng p1, final LatLng p2,
      {final LongitudeDirection lngDir = LongitudeDirection.greenwich}) {
    final dLat = p2.latitudeInRad - p1.latitudeInRad;
    final rawDLng = lngDir.effectiveLongitudinalDelta(p1, p2);

    // If |dLng| > pi we are on the long arc. Haversine only works with the
    // short-arc dLng, so we reduce it and then subtract from 2*pi at the end.
    final isLongArc = rawDLng.abs() > pi;
    final dLng = isLongArc ? rawDLng - (rawDLng > 0 ? tau : -tau) : rawDLng;

    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);

    // Sides
    final a = sinDLat * sinDLat +
        sinDLng * sinDLng * cos(p1.latitudeInRad) * cos(p2.latitudeInRad);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return equatorRadius * (isLongArc ? tau - c : c);
  }

  /// Returns a destination point based on the given [distance] and [bearing]
  ///
  /// Given a [from] (start) point, initial [bearing], and [distance],
  /// this will calculate the destination point and
  /// final bearing travelling along a (shortest distance) great circle arc.
  ///
  ///     final Haversine distance = const Haversine();
  ///
  ///     final double distanceInMeter = earthRadius * pi / 4;
  ///
  ///     final p1 = LatLng(0.0, 0.0);
  ///     final p2 = distance.offset(p1, distanceInMeter, 180);
  ///
  @override
  LatLng offset(
      final LatLng from, final double distanceInMeter, final double bearing) {
    if (bearing < -180 || bearing > 180) {
      throw ArgumentError.value(
          bearing, 'bearing', 'Angle must be between -180 and 180 degrees');
    }

    final h = degToRadian(bearing.toDouble());

    final a = distanceInMeter / equatorRadius;

    final lat2 = asin(sin(from.latitudeInRad) * cos(a) +
        cos(from.latitudeInRad) * sin(a) * cos(h));

    final lng2 = from.longitudeInRad +
        atan2(sin(h) * sin(a) * cos(from.latitudeInRad),
            cos(a) - sin(from.latitudeInRad) * sin(lat2));

    return LatLng(radianToDeg(lat2), radianToDeg(lng2));
  }

//- private -----------------------------------------------------------------------------------
}
