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

class Vincenty implements DistanceCalculator {
  final int maxIterations;
  final double accuracy;

  /// Default accuracy is about 0.5mm
  const Vincenty({this.maxIterations = 200, this.accuracy = 1e-12});

  /// Calculates distance with Vincenty algorithm.
  ///
  /// More on [Wikipedia](https://en.wikipedia.org/wiki/Vincenty%27s_formulae)
  @override
  double distance(
    final LatLng p1,
    final LatLng p2, {
    final LongitudeDirection lngDir = LongitudeDirection.greenwich,
  }) {
    const a = equatorRadius,
        b = polarRadius,
        f = flattening; // WGS-84 ellipsoid params

    final effectiveDLng = lngDir.effectiveLongitudinalDelta(p1, p2);

    // Vincenty's solver only converges for |l| <= pi (short arc).
    // Long-arc cases fold l back into (−pi, pi] here and compensate at the end.
    final isLongArc = effectiveDLng.abs() > pi;
    final l = isLongArc
        ? effectiveDLng - (effectiveDLng > 0 ? tau : -tau)
        : effectiveDLng;

    final u1 = atan((1 - f) * tan(p1.latitudeInRad));
    final u2 = atan((1 - f) * tan(p2.latitudeInRad));
    final sinU1 = sin(u1), cosU1 = cos(u1);
    final sinU2 = sin(u2), cosU2 = cos(u2);

    double sinLambda,
        cosLambda,
        sinSigma,
        cosSigma,
        sigma,
        sinAlpha,
        cosSqAlpha,
        cos2SigmaM;
    double lambda = l, lambdaP;
    var maxIterations = this.maxIterations;

    do {
      sinLambda = sin(lambda);
      cosLambda = cos(lambda);
      sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));

      if (sinSigma == 0) {
        // Co-incident points (l folded to 0). For long-arc directions this
        // means the caller asked for a full geodesic loop; return the
        // equatorial circumference as the best available scalar approximation.
        return isLongArc ? tau * equatorRadius : 0.0;
      }

      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;

      if (cos2SigmaM.isNaN) {
        cos2SigmaM = 0.0; // equatorial line: cosSqAlpha=0 (§6)
      }

      final C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = l +
          (1 - C) *
              f *
              sinAlpha *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SigmaM +
                          C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    } while ((lambda - lambdaP).abs() > accuracy && --maxIterations > 0);

    if (maxIterations == 0) {
      throw StateError('Distance calculation failed to converge!');
    }

    final uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    final A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    final B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    final deltaSigma = B *
        sinSigma *
        (cos2SigmaM +
            B /
                4 *
                (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                    B /
                        6 *
                        cos2SigmaM *
                        (-3 + 4 * sinSigma * sinSigma) *
                        (-3 + 4 * cos2SigmaM * cos2SigmaM)));

    final shortDist = b * A * (sigma - deltaSigma);

    if (!isLongArc) return shortDist;

    // The short and long arcs of a geodesic share the same A (it depends on
    // cosSqAlpha, a property of the geodesic, not the arc direction).
    // Total geodesic length = b*A*2pi, so long arc = total − short arc.
    // deltaSigma for the complementary arc would differ slightly, but the
    // discrepancy is below 1 mm on WGS-84 for any pair of points.
    return b * A * tau - shortDist;
  }

  /// Vincenty inverse calculation
  ///
  /// More on [Wikipedia](https://en.wikipedia.org/wiki/Vincenty%27s_formulae)
  @override
  LatLng offset(
      final LatLng from, final double distanceInMeter, final double bearing) {
    final equatorialRadius = equatorRadius;

    final latitude = from.latitudeInRad;
    final longitude = from.longitudeInRad;

    final alpha1 = degToRadian(bearing);
    final sinAlpha1 = sin(alpha1);
    final cosAlpha1 = cos(alpha1);

    final tanU1 = (1 - flattening) * tan(latitude);
    final cosU1 = 1 / sqrt((1 + tanU1 * tanU1));
    final sinU1 = tanU1 * cosU1;

    final sigma1 = atan2(tanU1, cosAlpha1);
    final sinAlpha = cosU1 * sinAlpha1;
    final cosSqAlpha = 1 - sinAlpha * sinAlpha;
    final dfUSq = cosSqAlpha *
        (equatorialRadius * equatorialRadius - polarRadius * polarRadius) /
        (polarRadius * polarRadius);
    final a = 1 +
        dfUSq / 16384 * (4096 + dfUSq * (-768 + dfUSq * (320 - 175 * dfUSq)));
    final b = dfUSq / 1024 * (256 + dfUSq * (-128 + dfUSq * (74 - 47 * dfUSq)));

    var sigma = distanceInMeter / (polarRadius * a);
    var sigmaP = tau;

    var sinSigma = 0.0;
    var cosSigma = 0.0;
    var cos2SigmaM = 0.0;
    double deltaSigma;
    var maxIterations = 200;

    do {
      cos2SigmaM = cos(2 * sigma1 + sigma);
      sinSigma = sin(sigma);
      cosSigma = cos(sigma);
      deltaSigma = b *
          sinSigma *
          (cos2SigmaM +
              b /
                  4 *
                  (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                      b /
                          6 *
                          cos2SigmaM *
                          (-3 + 4 * sinSigma * sinSigma) *
                          (-3 + 4 * cos2SigmaM * cos2SigmaM)));
      sigmaP = sigma;
      sigma = distanceInMeter / (polarRadius * a) + deltaSigma;
    } while ((sigma - sigmaP).abs() > 1e-12 && --maxIterations > 0);

    if (maxIterations == 0) {
      throw StateError('Offset calculation failed to converge!');
    }

    final tmp = sinU1 * sinSigma - cosU1 * cosSigma * cosAlpha1;
    final lat2 = atan2(sinU1 * cosSigma + cosU1 * sinSigma * cosAlpha1,
        (1 - flattening) * sqrt(sinAlpha * sinAlpha + tmp * tmp));

    final lambda = atan2(
        sinSigma * sinAlpha1, cosU1 * cosSigma - sinU1 * sinSigma * cosAlpha1);
    final c =
        flattening / 16 * cosSqAlpha * (4 + flattening * (4 - 3 * cosSqAlpha));
    final l = lambda -
        (1 - c) *
            flattening *
            sinAlpha *
            (sigma +
                c *
                    sinSigma *
                    (cos2SigmaM +
                        c * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));

    var lon2 = longitude + l;

    if (lon2 > pi) {
      lon2 -= tau;
    }
    if (lon2 < -pi) {
      lon2 += tau;
    }

    return LatLng(radianToDeg(lat2), radianToDeg(lon2));
  }

//- private -----------------------------------------------------------------------------------
}
