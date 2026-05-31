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

class Point2D {
  final double x;
  final double y;

  Point2D(this.x, this.y);
}

abstract class CatmullRom<R> {
  const CatmullRom();

  R position(final double distance);

  R percentage(final num percent) => position(percent / 100);
}

class CatmullRomSpline extends CatmullRom<double> {
  final double _p0, _p1, _p2, _p3;

  const CatmullRomSpline(this._p0, this._p1, this._p2, this._p3);

  const CatmullRomSpline.noEndpoints(final double p1, final double p2)
      : _p0 = p1,
        _p1 = p1,
        _p2 = p2,
        _p3 = p2;

  @override
  double position(final double distance) {
    if (distance < 0 || distance > 1) {
      throw ArgumentError.value(
          distance, 'distance', 'Distance must be between 0 and 1.');
    }

    return 0.5 *
        ((2 * _p1) +
            (_p2 - _p0) * distance +
            (2 * _p0 - 5 * _p1 + 4 * _p2 - _p3) * distance * distance +
            (3 * _p1 - _p0 - 3 * _p2 + _p3) * distance * distance * distance);
  }
}

class CatmullRomSpline2D<T extends num> extends CatmullRom<Point2D> {
  final Point2D _p0;
  final Point2D _p1;
  final Point2D _p2;
  final Point2D _p3;

  CatmullRomSpline2D(this._p0, this._p1, this._p2, this._p3);

  CatmullRomSpline2D.noEndpoints(final Point2D p0, final Point2D p1)
      : _p0 = p0,
        _p1 = p0,
        _p2 = p1,
        _p3 = p1;

  @override
  Point2D position(final double distance) {
    if (distance < 0 || distance > 1) {
      throw ArgumentError.value(
          distance, 'distance', 'Distance must be between 0 and 1.');
    }

    return Point2D(
        CatmullRomSpline(_p0.x, _p1.x, _p2.x, _p3.x).position(distance),
        CatmullRomSpline(_p0.y, _p1.y, _p2.y, _p3.y).position(distance));
  }
}
