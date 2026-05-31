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

import 'package:latlong2/latlong2.dart';

/// Circle-base GEO algorithms.
///
/// Circle uses by default the Vincenty-Algorithm for distance computations
class Circle {
  final double radius;
  final LatLng center;
  final DistanceCalculator _calculator;

  const Circle(this.center, this.radius,
      {final DistanceCalculator calculator = const Vincenty()})
      : _calculator = calculator;

  /// Checks if a [point] is inside the given [Circle]
  ///
  ///     final Circle circle = Circle(LatLng(0.0,0.0), 111319.0);
  ///     final LatLng newPos = LatLng(1.0,0.0);
  ///
  ///     expect(circle.isPointInside(newPos),isTrue);
  ///
  ///     final Circle circle2 = Circle(LatLng(0.0,0.0), 111318.0);
  ///
  ///     expect(circle2.isPointInside(newPos),isFalse);
  ///
  bool isPointInside(final LatLng point) {
    final distance = Distance(calculator: _calculator);

    final dist = distance(center, point);
    return dist <= radius;
  }

//- private -----------------------------------------------------------------------------------
}
