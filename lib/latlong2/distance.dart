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

/// Calculates the distance between points.
///
/// Default algorithm is [Vincenty], default radius is [earthRadius]
///
///      final Distance distance = Distance();
///
///      // km = 423
///      final double km = distance.as(LengthUnit.kilometer,
///          LatLng(52.518611,13.408056), LatLng(51.519475,7.46694444));
///
///      // meter = 422592
///      final double meter = distance(LatLng(52.518611,13.408056), LatLng(51.519475,7.46694444));
///
class Distance implements DistanceCalculator {
  final double _radius;
  final bool _roundResult;
  final DistanceCalculator _calculator;

  const Distance(
      {final bool roundResult = true,
      final DistanceCalculator calculator = const Vincenty()})
      : _radius = earthRadius,
        _roundResult = roundResult,
        _calculator = calculator;

  /// Radius must be greater than 0.
  Distance.withRadius(final double radius,
      {final bool roundResult = true,
      final DistanceCalculator calculator = const Vincenty()})
      : _radius = radius,
        _roundResult = roundResult,
        _calculator = calculator {
    if (radius <= 0) {
      throw ArgumentError.value(
          radius, 'radius', 'Radius must be greater than 0');
    }
  }

  double get radius => _radius;

  /// Returns either [Haversine] oder [Vincenty] calculator
  ///
  ///     final Distance distance = const DistanceHaversine();
  ///     final Circle circle = Circle(base, 1000.0,calculator: distance.calculator);
  ///
  DistanceCalculator get calculator => _calculator;

  /// Shortcut for [distance]
  double call(final LatLng p1, final LatLng p2,
      {final LongitudeDirection lngDir = LongitudeDirection.greenwich}) {
    return distance(p1, p2, lngDir: lngDir);
  }

  /// Converts the distance to the given [LengthUnit]
  ///
  ///     const Distance distance = Distance();
  ///     final double km = distance.as(LengthUnit.kilometer,
  ///          LatLng(52.518611,13.408056), LatLng(51.519475,7.46694444));
  ///
  double as(final LengthUnit unit, final LatLng p1, final LatLng p2) {
    final dist = _calculator.distance(p1, p2);

    // If the distance is NaN or infinite, return 0.0
    if (dist.isNaN || dist.isInfinite) {
      return 0.0;
    }

    return _round(LengthUnit.meter.to(unit, dist));
  }

  /// Computes the distance between two points.
  ///
  /// The function uses the [DistanceCalculator] specified in the CTOR
  @override
  double distance(final LatLng p1, final LatLng p2,
          {final LongitudeDirection lngDir = LongitudeDirection.greenwich}) =>
      _round(_calculator.distance(p1, p2, lngDir: lngDir));

  /// Returns the great circle bearing (direction) in degrees to the next point ([p2])
  ///
  /// Find out about the difference between rhumb line and
  /// great circle bearing on [Wikipedia](http://en.wikipedia.org/wiki/Rhumb_line#General_and_mathematical_description).
  ///
  ///     final Distance distance = const Distance();
  ///
  ///     final LatLng p1 = LatLng(0.0, 0.0);
  ///     final LatLng p2 = LatLng(-90.0, 0.0);
  ///
  ///     expect(distance.bearing(p1, p2), equals(180));
  double bearing(final LatLng p1, final LatLng p2) {
    final diffLongitude = p2.longitudeInRad - p1.longitudeInRad;

    final y = sin(diffLongitude);
    final x = cos(p1.latitudeInRad) * tan(p2.latitudeInRad) -
        sin(p1.latitudeInRad) * cos(diffLongitude);

    return radianToDeg(atan2(y, x));
  }

  /// Returns a destination point based on the given [distance] and [bearing]
  ///
  /// Given a [from] (start) point, initial [bearing], and [distance],
  /// this will calculate the destination point and
  /// final bearing travelling along a (shortest distance) great circle arc.
  ///
  ///     final Distance distance = const Distance();
  ///
  ///     final num distanceInMeter = (earthRadius * pi / 4).round();
  ///
  ///     final p1 = LatLng(0.0, 0.0);
  ///     final p2 = distance.offset(p1, distanceInMeter, 180);
  ///
  /// Bearing: Left - 270°, right - 90°, up - 0°, down - 180°
  @override
  LatLng offset(
          final LatLng from, final num distanceInMeter, final num bearing) =>
      _calculator.offset(from, distanceInMeter.toDouble(), bearing.toDouble());

  //- private -----------------------------------------------------------------------------------

  double _round(final double value) =>
      (_roundResult ? value.round().toDouble() : value);
}

/// Shortcut for
///     final Distance distance = const Distance(calculator: Vincenty());
///
class DistanceVincenty extends Distance {
  const DistanceVincenty({super.roundResult})
      : super(calculator: const Vincenty());

  /// Radius must be greater than 0.
  DistanceVincenty.withRadius(final double radius,
      {final bool roundResult = true})
      : super.withRadius(radius,
            roundResult: roundResult, calculator: const Vincenty()) {
    if (radius <= 0) {
      throw ArgumentError.value(
          radius, 'radius', 'Radius must be greater than 0');
    }
  }
}

/// Shortcut for
///     final Distance distance = const Distance(calculator: Haversine());
///
class DistanceHaversine extends Distance {
  const DistanceHaversine({super.roundResult})
      : super(calculator: const Haversine());

  /// Radius must be greater than 0.
  DistanceHaversine.withRadius(final double radius,
      {final bool roundResult = true})
      : super.withRadius(radius,
            roundResult: roundResult, calculator: const Haversine()) {
    if (radius <= 0) {
      throw ArgumentError.value(
          radius, 'radius', 'Radius must be greater than 0');
    }
  }
}
