## [1.0.0-dev.3]

- Renamed `LongitudeDirection#lazy` -> `LongitudeDirection#greenwich`
- Fix API reference and split code into proper `lib/src` structure

## [1.0.0-dev.2]

- Renamed `SegmentDirection` -> `LongitudeDirection`
- Renamed `effectiveDLng` -> `effectiveLongitudinalDelta`
- Removed `laziest` direction (did not really make sense either way...)
- Improved a few exceptions

## [1.0.0-dev.1]

- Added `SegmentDirection` interface for specifying in which direction distances should be calculated
- Allow more customisation in `Vincenty`
- Updated and fixed documentation
- Fixed a few typos here and there

## [1.0.0-dev.0]

- **Breaking change**: Renamed all files to snake_case
- Apply proper analyzer rules
- Specify dev_dependencies versions

## [0.10.1]

- **New maintainer: ThexXTURBOXx (Nico Mexis)**
- Improved `LatLng.hashCode` properly, reducing collisions (old hash function was worse).
- Reorganised pubspec and fixed license on pub.dev

## [0.10.0]

- Improved `LatLng.hashCode` to use XOR (`^`) instead of addition, reducing collisions.
- Safer `LatLng.fromJson` parsing: coordinates are now cast via `num` before converting to `double`.
- Documentation cleanup: removed `new` keyword from all examples, updated return types.
- Add `LatLng.isValid` getter for explicit bounds checking (latitude ∈ [-90, 90], longitude ∈ [-180, 180]).
- Fix Range tests to reflect that latitude/longitude boundary assertions were removed in 0.9.1.

## [0.9.1]

- Remove debug assertions on latitude and longitude boundaries.

## [0.9.0]

- Change to const constructor for `LatLng`.
- remove `setLatitude()` and `setLongitude()`.
- Bump minimum dart version to 3.0.

## [0.8.2]

- Sexagesimal fixes and utils
- Upgrade dependencies

## [0.8.1]

- Add GeoJSON compliant toJson() and fromJson().

## [0.8.0]

- Use pedantic.
- camelCase constants.
- Add example.
- Other lint fixes.

## [0.7.0]

- Support null safety, forked from the original repo, which is now archived.
- Address https://github.com/MikeMitterer/dart-latlong/issues/1 and issue 2.

For previous releases, see https://pub.dev/packages/latlong/changelog.
