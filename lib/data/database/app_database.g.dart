// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RunsTable extends Runs with TableInfo<$RunsTable, RunData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgPaceSecondsPerKmMeta =
      const VerificationMeta('avgPaceSecondsPerKm');
  @override
  late final GeneratedColumn<double> avgPaceSecondsPerKm =
      GeneratedColumn<double>(
        'avg_pace_seconds_per_km',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _routePointsJsonMeta = const VerificationMeta(
    'routePointsJson',
  );
  @override
  late final GeneratedColumn<String> routePointsJson = GeneratedColumn<String>(
    'route_points_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lapsJsonMeta = const VerificationMeta(
    'lapsJson',
  );
  @override
  late final GeneratedColumn<String> lapsJson = GeneratedColumn<String>(
    'laps_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _elevationLossMetersMeta =
      const VerificationMeta('elevationLossMeters');
  @override
  late final GeneratedColumn<double> elevationLossMeters =
      GeneratedColumn<double>(
        'elevation_loss_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateZonesJsonMeta =
      const VerificationMeta('heartRateZonesJson');
  @override
  late final GeneratedColumn<String> heartRateZonesJson =
      GeneratedColumn<String>(
        'heart_rate_zones_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<double> avgCadence = GeneratedColumn<double>(
    'avg_cadence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shoeIdMeta = const VerificationMeta('shoeId');
  @override
  late final GeneratedColumn<String> shoeId = GeneratedColumn<String>(
    'shoe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherJsonMeta = const VerificationMeta(
    'weatherJson',
  );
  @override
  late final GeneratedColumn<String> weatherJson = GeneratedColumn<String>(
    'weather_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherTempCelsiusMeta =
      const VerificationMeta('weatherTempCelsius');
  @override
  late final GeneratedColumn<double> weatherTempCelsius =
      GeneratedColumn<double>(
        'weather_temp_celsius',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    distanceMeters,
    durationSeconds,
    avgPaceSecondsPerKm,
    routePointsJson,
    lapsJson,
    elevationGainMeters,
    elevationLossMeters,
    avgHeartRate,
    maxHeartRate,
    heartRateZonesJson,
    avgCadence,
    shoeId,
    weatherJson,
    weatherTempCelsius,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('avg_pace_seconds_per_km')) {
      context.handle(
        _avgPaceSecondsPerKmMeta,
        avgPaceSecondsPerKm.isAcceptableOrUnknown(
          data['avg_pace_seconds_per_km']!,
          _avgPaceSecondsPerKmMeta,
        ),
      );
    }
    if (data.containsKey('route_points_json')) {
      context.handle(
        _routePointsJsonMeta,
        routePointsJson.isAcceptableOrUnknown(
          data['route_points_json']!,
          _routePointsJsonMeta,
        ),
      );
    }
    if (data.containsKey('laps_json')) {
      context.handle(
        _lapsJsonMeta,
        lapsJson.isAcceptableOrUnknown(data['laps_json']!, _lapsJsonMeta),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss_meters')) {
      context.handle(
        _elevationLossMetersMeta,
        elevationLossMeters.isAcceptableOrUnknown(
          data['elevation_loss_meters']!,
          _elevationLossMetersMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('heart_rate_zones_json')) {
      context.handle(
        _heartRateZonesJsonMeta,
        heartRateZonesJson.isAcceptableOrUnknown(
          data['heart_rate_zones_json']!,
          _heartRateZonesJsonMeta,
        ),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    if (data.containsKey('shoe_id')) {
      context.handle(
        _shoeIdMeta,
        shoeId.isAcceptableOrUnknown(data['shoe_id']!, _shoeIdMeta),
      );
    }
    if (data.containsKey('weather_json')) {
      context.handle(
        _weatherJsonMeta,
        weatherJson.isAcceptableOrUnknown(
          data['weather_json']!,
          _weatherJsonMeta,
        ),
      );
    }
    if (data.containsKey('weather_temp_celsius')) {
      context.handle(
        _weatherTempCelsiusMeta,
        weatherTempCelsius.isAcceptableOrUnknown(
          data['weather_temp_celsius']!,
          _weatherTempCelsiusMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      avgPaceSecondsPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_pace_seconds_per_km'],
      ),
      routePointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_points_json'],
      ),
      lapsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}laps_json'],
      ),
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      ),
      elevationLossMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss_meters'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      ),
      heartRateZonesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heart_rate_zones_json'],
      ),
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_cadence'],
      ),
      shoeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shoe_id'],
      ),
      weatherJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_json'],
      ),
      weatherTempCelsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_temp_celsius'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }
}

class RunData extends DataClass implements Insertable<RunData> {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double? distanceMeters;
  final int? durationSeconds;
  final double? avgPaceSecondsPerKm;
  final String? routePointsJson;
  final String? lapsJson;
  final double? elevationGainMeters;
  final double? elevationLossMeters;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final String? heartRateZonesJson;
  final double? avgCadence;
  final String? shoeId;
  final String? weatherJson;
  final double? weatherTempCelsius;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RunData({
    required this.id,
    required this.startTime,
    this.endTime,
    this.distanceMeters,
    this.durationSeconds,
    this.avgPaceSecondsPerKm,
    this.routePointsJson,
    this.lapsJson,
    this.elevationGainMeters,
    this.elevationLossMeters,
    this.avgHeartRate,
    this.maxHeartRate,
    this.heartRateZonesJson,
    this.avgCadence,
    this.shoeId,
    this.weatherJson,
    this.weatherTempCelsius,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || avgPaceSecondsPerKm != null) {
      map['avg_pace_seconds_per_km'] = Variable<double>(avgPaceSecondsPerKm);
    }
    if (!nullToAbsent || routePointsJson != null) {
      map['route_points_json'] = Variable<String>(routePointsJson);
    }
    if (!nullToAbsent || lapsJson != null) {
      map['laps_json'] = Variable<String>(lapsJson);
    }
    if (!nullToAbsent || elevationGainMeters != null) {
      map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    }
    if (!nullToAbsent || elevationLossMeters != null) {
      map['elevation_loss_meters'] = Variable<double>(elevationLossMeters);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || heartRateZonesJson != null) {
      map['heart_rate_zones_json'] = Variable<String>(heartRateZonesJson);
    }
    if (!nullToAbsent || avgCadence != null) {
      map['avg_cadence'] = Variable<double>(avgCadence);
    }
    if (!nullToAbsent || shoeId != null) {
      map['shoe_id'] = Variable<String>(shoeId);
    }
    if (!nullToAbsent || weatherJson != null) {
      map['weather_json'] = Variable<String>(weatherJson);
    }
    if (!nullToAbsent || weatherTempCelsius != null) {
      map['weather_temp_celsius'] = Variable<double>(weatherTempCelsius);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      avgPaceSecondsPerKm: avgPaceSecondsPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPaceSecondsPerKm),
      routePointsJson: routePointsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(routePointsJson),
      lapsJson: lapsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(lapsJson),
      elevationGainMeters: elevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainMeters),
      elevationLossMeters: elevationLossMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationLossMeters),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      heartRateZonesJson: heartRateZonesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateZonesJson),
      avgCadence: avgCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadence),
      shoeId: shoeId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoeId),
      weatherJson: weatherJson == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherJson),
      weatherTempCelsius: weatherTempCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherTempCelsius),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RunData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunData(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      avgPaceSecondsPerKm: serializer.fromJson<double?>(
        json['avgPaceSecondsPerKm'],
      ),
      routePointsJson: serializer.fromJson<String?>(json['routePointsJson']),
      lapsJson: serializer.fromJson<String?>(json['lapsJson']),
      elevationGainMeters: serializer.fromJson<double?>(
        json['elevationGainMeters'],
      ),
      elevationLossMeters: serializer.fromJson<double?>(
        json['elevationLossMeters'],
      ),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      heartRateZonesJson: serializer.fromJson<String?>(
        json['heartRateZonesJson'],
      ),
      avgCadence: serializer.fromJson<double?>(json['avgCadence']),
      shoeId: serializer.fromJson<String?>(json['shoeId']),
      weatherJson: serializer.fromJson<String?>(json['weatherJson']),
      weatherTempCelsius: serializer.fromJson<double?>(
        json['weatherTempCelsius'],
      ),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'avgPaceSecondsPerKm': serializer.toJson<double?>(avgPaceSecondsPerKm),
      'routePointsJson': serializer.toJson<String?>(routePointsJson),
      'lapsJson': serializer.toJson<String?>(lapsJson),
      'elevationGainMeters': serializer.toJson<double?>(elevationGainMeters),
      'elevationLossMeters': serializer.toJson<double?>(elevationLossMeters),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'heartRateZonesJson': serializer.toJson<String?>(heartRateZonesJson),
      'avgCadence': serializer.toJson<double?>(avgCadence),
      'shoeId': serializer.toJson<String?>(shoeId),
      'weatherJson': serializer.toJson<String?>(weatherJson),
      'weatherTempCelsius': serializer.toJson<double?>(weatherTempCelsius),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RunData copyWith({
    String? id,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<double?> avgPaceSecondsPerKm = const Value.absent(),
    Value<String?> routePointsJson = const Value.absent(),
    Value<String?> lapsJson = const Value.absent(),
    Value<double?> elevationGainMeters = const Value.absent(),
    Value<double?> elevationLossMeters = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> maxHeartRate = const Value.absent(),
    Value<String?> heartRateZonesJson = const Value.absent(),
    Value<double?> avgCadence = const Value.absent(),
    Value<String?> shoeId = const Value.absent(),
    Value<String?> weatherJson = const Value.absent(),
    Value<double?> weatherTempCelsius = const Value.absent(),
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RunData(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    avgPaceSecondsPerKm: avgPaceSecondsPerKm.present
        ? avgPaceSecondsPerKm.value
        : this.avgPaceSecondsPerKm,
    routePointsJson: routePointsJson.present
        ? routePointsJson.value
        : this.routePointsJson,
    lapsJson: lapsJson.present ? lapsJson.value : this.lapsJson,
    elevationGainMeters: elevationGainMeters.present
        ? elevationGainMeters.value
        : this.elevationGainMeters,
    elevationLossMeters: elevationLossMeters.present
        ? elevationLossMeters.value
        : this.elevationLossMeters,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    heartRateZonesJson: heartRateZonesJson.present
        ? heartRateZonesJson.value
        : this.heartRateZonesJson,
    avgCadence: avgCadence.present ? avgCadence.value : this.avgCadence,
    shoeId: shoeId.present ? shoeId.value : this.shoeId,
    weatherJson: weatherJson.present ? weatherJson.value : this.weatherJson,
    weatherTempCelsius: weatherTempCelsius.present
        ? weatherTempCelsius.value
        : this.weatherTempCelsius,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RunData copyWithCompanion(RunsCompanion data) {
    return RunData(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      avgPaceSecondsPerKm: data.avgPaceSecondsPerKm.present
          ? data.avgPaceSecondsPerKm.value
          : this.avgPaceSecondsPerKm,
      routePointsJson: data.routePointsJson.present
          ? data.routePointsJson.value
          : this.routePointsJson,
      lapsJson: data.lapsJson.present ? data.lapsJson.value : this.lapsJson,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      elevationLossMeters: data.elevationLossMeters.present
          ? data.elevationLossMeters.value
          : this.elevationLossMeters,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      heartRateZonesJson: data.heartRateZonesJson.present
          ? data.heartRateZonesJson.value
          : this.heartRateZonesJson,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
      shoeId: data.shoeId.present ? data.shoeId.value : this.shoeId,
      weatherJson: data.weatherJson.present
          ? data.weatherJson.value
          : this.weatherJson,
      weatherTempCelsius: data.weatherTempCelsius.present
          ? data.weatherTempCelsius.value
          : this.weatherTempCelsius,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunData(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSecondsPerKm: $avgPaceSecondsPerKm, ')
          ..write('routePointsJson: $routePointsJson, ')
          ..write('lapsJson: $lapsJson, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('elevationLossMeters: $elevationLossMeters, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('heartRateZonesJson: $heartRateZonesJson, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('shoeId: $shoeId, ')
          ..write('weatherJson: $weatherJson, ')
          ..write('weatherTempCelsius: $weatherTempCelsius, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    distanceMeters,
    durationSeconds,
    avgPaceSecondsPerKm,
    routePointsJson,
    lapsJson,
    elevationGainMeters,
    elevationLossMeters,
    avgHeartRate,
    maxHeartRate,
    heartRateZonesJson,
    avgCadence,
    shoeId,
    weatherJson,
    weatherTempCelsius,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunData &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.distanceMeters == this.distanceMeters &&
          other.durationSeconds == this.durationSeconds &&
          other.avgPaceSecondsPerKm == this.avgPaceSecondsPerKm &&
          other.routePointsJson == this.routePointsJson &&
          other.lapsJson == this.lapsJson &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.elevationLossMeters == this.elevationLossMeters &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.heartRateZonesJson == this.heartRateZonesJson &&
          other.avgCadence == this.avgCadence &&
          other.shoeId == this.shoeId &&
          other.weatherJson == this.weatherJson &&
          other.weatherTempCelsius == this.weatherTempCelsius &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RunsCompanion extends UpdateCompanion<RunData> {
  final Value<String> id;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<double?> distanceMeters;
  final Value<int?> durationSeconds;
  final Value<double?> avgPaceSecondsPerKm;
  final Value<String?> routePointsJson;
  final Value<String?> lapsJson;
  final Value<double?> elevationGainMeters;
  final Value<double?> elevationLossMeters;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<String?> heartRateZonesJson;
  final Value<double?> avgCadence;
  final Value<String?> shoeId;
  final Value<String?> weatherJson;
  final Value<double?> weatherTempCelsius;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.avgPaceSecondsPerKm = const Value.absent(),
    this.routePointsJson = const Value.absent(),
    this.lapsJson = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.elevationLossMeters = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.heartRateZonesJson = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.weatherJson = const Value.absent(),
    this.weatherTempCelsius = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunsCompanion.insert({
    required String id,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.avgPaceSecondsPerKm = const Value.absent(),
    this.routePointsJson = const Value.absent(),
    this.lapsJson = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.elevationLossMeters = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.heartRateZonesJson = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.weatherJson = const Value.absent(),
    this.weatherTempCelsius = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime);
  static Insertable<RunData> custom({
    Expression<String>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<double>? distanceMeters,
    Expression<int>? durationSeconds,
    Expression<double>? avgPaceSecondsPerKm,
    Expression<String>? routePointsJson,
    Expression<String>? lapsJson,
    Expression<double>? elevationGainMeters,
    Expression<double>? elevationLossMeters,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<String>? heartRateZonesJson,
    Expression<double>? avgCadence,
    Expression<String>? shoeId,
    Expression<String>? weatherJson,
    Expression<double>? weatherTempCelsius,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (avgPaceSecondsPerKm != null)
        'avg_pace_seconds_per_km': avgPaceSecondsPerKm,
      if (routePointsJson != null) 'route_points_json': routePointsJson,
      if (lapsJson != null) 'laps_json': lapsJson,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (elevationLossMeters != null)
        'elevation_loss_meters': elevationLossMeters,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (heartRateZonesJson != null)
        'heart_rate_zones_json': heartRateZonesJson,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (shoeId != null) 'shoe_id': shoeId,
      if (weatherJson != null) 'weather_json': weatherJson,
      if (weatherTempCelsius != null)
        'weather_temp_celsius': weatherTempCelsius,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<double?>? distanceMeters,
    Value<int?>? durationSeconds,
    Value<double?>? avgPaceSecondsPerKm,
    Value<String?>? routePointsJson,
    Value<String?>? lapsJson,
    Value<double?>? elevationGainMeters,
    Value<double?>? elevationLossMeters,
    Value<int?>? avgHeartRate,
    Value<int?>? maxHeartRate,
    Value<String?>? heartRateZonesJson,
    Value<double?>? avgCadence,
    Value<String?>? shoeId,
    Value<String?>? weatherJson,
    Value<double?>? weatherTempCelsius,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
      routePointsJson: routePointsJson ?? this.routePointsJson,
      lapsJson: lapsJson ?? this.lapsJson,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      heartRateZonesJson: heartRateZonesJson ?? this.heartRateZonesJson,
      avgCadence: avgCadence ?? this.avgCadence,
      shoeId: shoeId ?? this.shoeId,
      weatherJson: weatherJson ?? this.weatherJson,
      weatherTempCelsius: weatherTempCelsius ?? this.weatherTempCelsius,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (avgPaceSecondsPerKm.present) {
      map['avg_pace_seconds_per_km'] = Variable<double>(
        avgPaceSecondsPerKm.value,
      );
    }
    if (routePointsJson.present) {
      map['route_points_json'] = Variable<String>(routePointsJson.value);
    }
    if (lapsJson.present) {
      map['laps_json'] = Variable<String>(lapsJson.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (elevationLossMeters.present) {
      map['elevation_loss_meters'] = Variable<double>(
        elevationLossMeters.value,
      );
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (heartRateZonesJson.present) {
      map['heart_rate_zones_json'] = Variable<String>(heartRateZonesJson.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<double>(avgCadence.value);
    }
    if (shoeId.present) {
      map['shoe_id'] = Variable<String>(shoeId.value);
    }
    if (weatherJson.present) {
      map['weather_json'] = Variable<String>(weatherJson.value);
    }
    if (weatherTempCelsius.present) {
      map['weather_temp_celsius'] = Variable<double>(weatherTempCelsius.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('avgPaceSecondsPerKm: $avgPaceSecondsPerKm, ')
          ..write('routePointsJson: $routePointsJson, ')
          ..write('lapsJson: $lapsJson, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('elevationLossMeters: $elevationLossMeters, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('heartRateZonesJson: $heartRateZonesJson, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('shoeId: $shoeId, ')
          ..write('weatherJson: $weatherJson, ')
          ..write('weatherTempCelsius: $weatherTempCelsius, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoesTable extends Shoes with TableInfo<$ShoesTable, ShoeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialMileageMetersMeta =
      const VerificationMeta('initialMileageMeters');
  @override
  late final GeneratedColumn<double> initialMileageMeters =
      GeneratedColumn<double>(
        'initial_mileage_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _targetMileageMetersMeta =
      const VerificationMeta('targetMileageMeters');
  @override
  late final GeneratedColumn<double> targetMileageMeters =
      GeneratedColumn<double>(
        'target_mileage_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<bool> retired = GeneratedColumn<bool>(
    'retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    model,
    initialMileageMeters,
    targetMileageMeters,
    retired,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('initial_mileage_meters')) {
      context.handle(
        _initialMileageMetersMeta,
        initialMileageMeters.isAcceptableOrUnknown(
          data['initial_mileage_meters']!,
          _initialMileageMetersMeta,
        ),
      );
    }
    if (data.containsKey('target_mileage_meters')) {
      context.handle(
        _targetMileageMetersMeta,
        targetMileageMeters.isAcceptableOrUnknown(
          data['target_mileage_meters']!,
          _targetMileageMetersMeta,
        ),
      );
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      initialMileageMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_mileage_meters'],
      )!,
      targetMileageMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_mileage_meters'],
      ),
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retired'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShoesTable createAlias(String alias) {
    return $ShoesTable(attachedDatabase, alias);
  }
}

class ShoeData extends DataClass implements Insertable<ShoeData> {
  final String id;
  final String name;
  final String? brand;
  final String? model;
  final double initialMileageMeters;
  final double? targetMileageMeters;
  final bool retired;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoeData({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    required this.initialMileageMeters,
    this.targetMileageMeters,
    required this.retired,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['initial_mileage_meters'] = Variable<double>(initialMileageMeters);
    if (!nullToAbsent || targetMileageMeters != null) {
      map['target_mileage_meters'] = Variable<double>(targetMileageMeters);
    }
    map['retired'] = Variable<bool>(retired);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoesCompanion toCompanion(bool nullToAbsent) {
    return ShoesCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      initialMileageMeters: Value(initialMileageMeters),
      targetMileageMeters: targetMileageMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMileageMeters),
      retired: Value(retired),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoeData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      model: serializer.fromJson<String?>(json['model']),
      initialMileageMeters: serializer.fromJson<double>(
        json['initialMileageMeters'],
      ),
      targetMileageMeters: serializer.fromJson<double?>(
        json['targetMileageMeters'],
      ),
      retired: serializer.fromJson<bool>(json['retired']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'model': serializer.toJson<String?>(model),
      'initialMileageMeters': serializer.toJson<double>(initialMileageMeters),
      'targetMileageMeters': serializer.toJson<double?>(targetMileageMeters),
      'retired': serializer.toJson<bool>(retired),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoeData copyWith({
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> model = const Value.absent(),
    double? initialMileageMeters,
    Value<double?> targetMileageMeters = const Value.absent(),
    bool? retired,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShoeData(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    model: model.present ? model.value : this.model,
    initialMileageMeters: initialMileageMeters ?? this.initialMileageMeters,
    targetMileageMeters: targetMileageMeters.present
        ? targetMileageMeters.value
        : this.targetMileageMeters,
    retired: retired ?? this.retired,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ShoeData copyWithCompanion(ShoesCompanion data) {
    return ShoeData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      initialMileageMeters: data.initialMileageMeters.present
          ? data.initialMileageMeters.value
          : this.initialMileageMeters,
      targetMileageMeters: data.targetMileageMeters.present
          ? data.targetMileageMeters.value
          : this.targetMileageMeters,
      retired: data.retired.present ? data.retired.value : this.retired,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoeData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('initialMileageMeters: $initialMileageMeters, ')
          ..write('targetMileageMeters: $targetMileageMeters, ')
          ..write('retired: $retired, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    model,
    initialMileageMeters,
    targetMileageMeters,
    retired,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoeData &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.initialMileageMeters == this.initialMileageMeters &&
          other.targetMileageMeters == this.targetMileageMeters &&
          other.retired == this.retired &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoesCompanion extends UpdateCompanion<ShoeData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> model;
  final Value<double> initialMileageMeters;
  final Value<double?> targetMileageMeters;
  final Value<bool> retired;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.initialMileageMeters = const Value.absent(),
    this.targetMileageMeters = const Value.absent(),
    this.retired = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoesCompanion.insert({
    required String id,
    required String name,
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.initialMileageMeters = const Value.absent(),
    this.targetMileageMeters = const Value.absent(),
    this.retired = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ShoeData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<double>? initialMileageMeters,
    Expression<double>? targetMileageMeters,
    Expression<bool>? retired,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (initialMileageMeters != null)
        'initial_mileage_meters': initialMileageMeters,
      if (targetMileageMeters != null)
        'target_mileage_meters': targetMileageMeters,
      if (retired != null) 'retired': retired,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? model,
    Value<double>? initialMileageMeters,
    Value<double?>? targetMileageMeters,
    Value<bool>? retired,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShoesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      initialMileageMeters: initialMileageMeters ?? this.initialMileageMeters,
      targetMileageMeters: targetMileageMeters ?? this.targetMileageMeters,
      retired: retired ?? this.retired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (initialMileageMeters.present) {
      map['initial_mileage_meters'] = Variable<double>(
        initialMileageMeters.value,
      );
    }
    if (targetMileageMeters.present) {
      map['target_mileage_meters'] = Variable<double>(
        targetMileageMeters.value,
      );
    }
    if (retired.present) {
      map['retired'] = Variable<bool>(retired.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('initialMileageMeters: $initialMileageMeters, ')
          ..write('targetMileageMeters: $targetMileageMeters, ')
          ..write('retired: $retired, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceKeyMeta = const VerificationMeta(
    'distanceKey',
  );
  @override
  late final GeneratedColumn<String> distanceKey = GeneratedColumn<String>(
    'distance_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecondsMeta = const VerificationMeta(
    'timeSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSeconds = GeneratedColumn<int>(
    'time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceSecondsPerKmMeta = const VerificationMeta(
    'paceSecondsPerKm',
  );
  @override
  late final GeneratedColumn<double> paceSecondsPerKm = GeneratedColumn<double>(
    'pace_seconds_per_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    distanceKey,
    runId,
    timeSeconds,
    paceSecondsPerKm,
    achievedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('distance_key')) {
      context.handle(
        _distanceKeyMeta,
        distanceKey.isAcceptableOrUnknown(
          data['distance_key']!,
          _distanceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceKeyMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('time_seconds')) {
      context.handle(
        _timeSecondsMeta,
        timeSeconds.isAcceptableOrUnknown(
          data['time_seconds']!,
          _timeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSecondsMeta);
    }
    if (data.containsKey('pace_seconds_per_km')) {
      context.handle(
        _paceSecondsPerKmMeta,
        paceSecondsPerKm.isAcceptableOrUnknown(
          data['pace_seconds_per_km']!,
          _paceSecondsPerKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paceSecondsPerKmMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      distanceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_key'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      timeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_seconds'],
      )!,
      paceSecondsPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pace_seconds_per_km'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecordData extends DataClass
    implements Insertable<PersonalRecordData> {
  final String id;
  final String distanceKey;
  final String runId;
  final int timeSeconds;
  final double paceSecondsPerKm;
  final DateTime achievedAt;
  final DateTime createdAt;
  const PersonalRecordData({
    required this.id,
    required this.distanceKey,
    required this.runId,
    required this.timeSeconds,
    required this.paceSecondsPerKm,
    required this.achievedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['distance_key'] = Variable<String>(distanceKey);
    map['run_id'] = Variable<String>(runId);
    map['time_seconds'] = Variable<int>(timeSeconds);
    map['pace_seconds_per_km'] = Variable<double>(paceSecondsPerKm);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      distanceKey: Value(distanceKey),
      runId: Value(runId),
      timeSeconds: Value(timeSeconds),
      paceSecondsPerKm: Value(paceSecondsPerKm),
      achievedAt: Value(achievedAt),
      createdAt: Value(createdAt),
    );
  }

  factory PersonalRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecordData(
      id: serializer.fromJson<String>(json['id']),
      distanceKey: serializer.fromJson<String>(json['distanceKey']),
      runId: serializer.fromJson<String>(json['runId']),
      timeSeconds: serializer.fromJson<int>(json['timeSeconds']),
      paceSecondsPerKm: serializer.fromJson<double>(json['paceSecondsPerKm']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'distanceKey': serializer.toJson<String>(distanceKey),
      'runId': serializer.toJson<String>(runId),
      'timeSeconds': serializer.toJson<int>(timeSeconds),
      'paceSecondsPerKm': serializer.toJson<double>(paceSecondsPerKm),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PersonalRecordData copyWith({
    String? id,
    String? distanceKey,
    String? runId,
    int? timeSeconds,
    double? paceSecondsPerKm,
    DateTime? achievedAt,
    DateTime? createdAt,
  }) => PersonalRecordData(
    id: id ?? this.id,
    distanceKey: distanceKey ?? this.distanceKey,
    runId: runId ?? this.runId,
    timeSeconds: timeSeconds ?? this.timeSeconds,
    paceSecondsPerKm: paceSecondsPerKm ?? this.paceSecondsPerKm,
    achievedAt: achievedAt ?? this.achievedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  PersonalRecordData copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecordData(
      id: data.id.present ? data.id.value : this.id,
      distanceKey: data.distanceKey.present
          ? data.distanceKey.value
          : this.distanceKey,
      runId: data.runId.present ? data.runId.value : this.runId,
      timeSeconds: data.timeSeconds.present
          ? data.timeSeconds.value
          : this.timeSeconds,
      paceSecondsPerKm: data.paceSecondsPerKm.present
          ? data.paceSecondsPerKm.value
          : this.paceSecondsPerKm,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordData(')
          ..write('id: $id, ')
          ..write('distanceKey: $distanceKey, ')
          ..write('runId: $runId, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('paceSecondsPerKm: $paceSecondsPerKm, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    distanceKey,
    runId,
    timeSeconds,
    paceSecondsPerKm,
    achievedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecordData &&
          other.id == this.id &&
          other.distanceKey == this.distanceKey &&
          other.runId == this.runId &&
          other.timeSeconds == this.timeSeconds &&
          other.paceSecondsPerKm == this.paceSecondsPerKm &&
          other.achievedAt == this.achievedAt &&
          other.createdAt == this.createdAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecordData> {
  final Value<String> id;
  final Value<String> distanceKey;
  final Value<String> runId;
  final Value<int> timeSeconds;
  final Value<double> paceSecondsPerKm;
  final Value<DateTime> achievedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.distanceKey = const Value.absent(),
    this.runId = const Value.absent(),
    this.timeSeconds = const Value.absent(),
    this.paceSecondsPerKm = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    required String id,
    required String distanceKey,
    required String runId,
    required int timeSeconds,
    required double paceSecondsPerKm,
    required DateTime achievedAt,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       distanceKey = Value(distanceKey),
       runId = Value(runId),
       timeSeconds = Value(timeSeconds),
       paceSecondsPerKm = Value(paceSecondsPerKm),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecordData> custom({
    Expression<String>? id,
    Expression<String>? distanceKey,
    Expression<String>? runId,
    Expression<int>? timeSeconds,
    Expression<double>? paceSecondsPerKm,
    Expression<DateTime>? achievedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (distanceKey != null) 'distance_key': distanceKey,
      if (runId != null) 'run_id': runId,
      if (timeSeconds != null) 'time_seconds': timeSeconds,
      if (paceSecondsPerKm != null) 'pace_seconds_per_km': paceSecondsPerKm,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? distanceKey,
    Value<String>? runId,
    Value<int>? timeSeconds,
    Value<double>? paceSecondsPerKm,
    Value<DateTime>? achievedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      distanceKey: distanceKey ?? this.distanceKey,
      runId: runId ?? this.runId,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      paceSecondsPerKm: paceSecondsPerKm ?? this.paceSecondsPerKm,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (distanceKey.present) {
      map['distance_key'] = Variable<String>(distanceKey.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (timeSeconds.present) {
      map['time_seconds'] = Variable<int>(timeSeconds.value);
    }
    if (paceSecondsPerKm.present) {
      map['pace_seconds_per_km'] = Variable<double>(paceSecondsPerKm.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('distanceKey: $distanceKey, ')
          ..write('runId: $runId, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('paceSecondsPerKm: $paceSecondsPerKm, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $ShoesTable shoes = $ShoesTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final RunsDao runsDao = RunsDao(this as AppDatabase);
  late final ShoesDao shoesDao = ShoesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    runs,
    shoes,
    personalRecords,
  ];
}

typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      required String id,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<double?> distanceMeters,
      Value<int?> durationSeconds,
      Value<double?> avgPaceSecondsPerKm,
      Value<String?> routePointsJson,
      Value<String?> lapsJson,
      Value<double?> elevationGainMeters,
      Value<double?> elevationLossMeters,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<String?> heartRateZonesJson,
      Value<double?> avgCadence,
      Value<String?> shoeId,
      Value<String?> weatherJson,
      Value<double?> weatherTempCelsius,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<String> id,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<double?> distanceMeters,
      Value<int?> durationSeconds,
      Value<double?> avgPaceSecondsPerKm,
      Value<String?> routePointsJson,
      Value<String?> lapsJson,
      Value<double?> elevationGainMeters,
      Value<double?> elevationLossMeters,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<String?> heartRateZonesJson,
      Value<double?> avgCadence,
      Value<String?> shoeId,
      Value<String?> weatherJson,
      Value<double?> weatherTempCelsius,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPaceSecondsPerKm => $composableBuilder(
    column: $table.avgPaceSecondsPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lapsJson => $composableBuilder(
    column: $table.lapsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heartRateZonesJson => $composableBuilder(
    column: $table.heartRateZonesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shoeId => $composableBuilder(
    column: $table.shoeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherTempCelsius => $composableBuilder(
    column: $table.weatherTempCelsius,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPaceSecondsPerKm => $composableBuilder(
    column: $table.avgPaceSecondsPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lapsJson => $composableBuilder(
    column: $table.lapsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heartRateZonesJson => $composableBuilder(
    column: $table.heartRateZonesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shoeId => $composableBuilder(
    column: $table.shoeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherTempCelsius => $composableBuilder(
    column: $table.weatherTempCelsius,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgPaceSecondsPerKm => $composableBuilder(
    column: $table.avgPaceSecondsPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lapsJson =>
      $composableBuilder(column: $table.lapsJson, builder: (column) => column);

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heartRateZonesJson => $composableBuilder(
    column: $table.heartRateZonesJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shoeId =>
      $composableBuilder(column: $table.shoeId, builder: (column) => column);

  GeneratedColumn<String> get weatherJson => $composableBuilder(
    column: $table.weatherJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherTempCelsius => $composableBuilder(
    column: $table.weatherTempCelsius,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          RunData,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (RunData, BaseReferences<_$AppDatabase, $RunsTable, RunData>),
          RunData,
          PrefetchHooks Function()
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> avgPaceSecondsPerKm = const Value.absent(),
                Value<String?> routePointsJson = const Value.absent(),
                Value<String?> lapsJson = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<double?> elevationLossMeters = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<String?> heartRateZonesJson = const Value.absent(),
                Value<double?> avgCadence = const Value.absent(),
                Value<String?> shoeId = const Value.absent(),
                Value<String?> weatherJson = const Value.absent(),
                Value<double?> weatherTempCelsius = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                avgPaceSecondsPerKm: avgPaceSecondsPerKm,
                routePointsJson: routePointsJson,
                lapsJson: lapsJson,
                elevationGainMeters: elevationGainMeters,
                elevationLossMeters: elevationLossMeters,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                heartRateZonesJson: heartRateZonesJson,
                avgCadence: avgCadence,
                shoeId: shoeId,
                weatherJson: weatherJson,
                weatherTempCelsius: weatherTempCelsius,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> avgPaceSecondsPerKm = const Value.absent(),
                Value<String?> routePointsJson = const Value.absent(),
                Value<String?> lapsJson = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<double?> elevationLossMeters = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<String?> heartRateZonesJson = const Value.absent(),
                Value<double?> avgCadence = const Value.absent(),
                Value<String?> shoeId = const Value.absent(),
                Value<String?> weatherJson = const Value.absent(),
                Value<double?> weatherTempCelsius = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                distanceMeters: distanceMeters,
                durationSeconds: durationSeconds,
                avgPaceSecondsPerKm: avgPaceSecondsPerKm,
                routePointsJson: routePointsJson,
                lapsJson: lapsJson,
                elevationGainMeters: elevationGainMeters,
                elevationLossMeters: elevationLossMeters,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                heartRateZonesJson: heartRateZonesJson,
                avgCadence: avgCadence,
                shoeId: shoeId,
                weatherJson: weatherJson,
                weatherTempCelsius: weatherTempCelsius,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      RunData,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (RunData, BaseReferences<_$AppDatabase, $RunsTable, RunData>),
      RunData,
      PrefetchHooks Function()
    >;
typedef $$ShoesTableCreateCompanionBuilder =
    ShoesCompanion Function({
      required String id,
      required String name,
      Value<String?> brand,
      Value<String?> model,
      Value<double> initialMileageMeters,
      Value<double?> targetMileageMeters,
      Value<bool> retired,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ShoesTableUpdateCompanionBuilder =
    ShoesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> brand,
      Value<String?> model,
      Value<double> initialMileageMeters,
      Value<double?> targetMileageMeters,
      Value<bool> retired,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ShoesTableFilterComposer extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialMileageMeters => $composableBuilder(
    column: $table.initialMileageMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetMileageMeters => $composableBuilder(
    column: $table.targetMileageMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShoesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialMileageMeters => $composableBuilder(
    column: $table.initialMileageMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetMileageMeters => $composableBuilder(
    column: $table.targetMileageMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<double> get initialMileageMeters => $composableBuilder(
    column: $table.initialMileageMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetMileageMeters => $composableBuilder(
    column: $table.targetMileageMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoesTable,
          ShoeData,
          $$ShoesTableFilterComposer,
          $$ShoesTableOrderingComposer,
          $$ShoesTableAnnotationComposer,
          $$ShoesTableCreateCompanionBuilder,
          $$ShoesTableUpdateCompanionBuilder,
          (ShoeData, BaseReferences<_$AppDatabase, $ShoesTable, ShoeData>),
          ShoeData,
          PrefetchHooks Function()
        > {
  $$ShoesTableTableManager(_$AppDatabase db, $ShoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<double> initialMileageMeters = const Value.absent(),
                Value<double?> targetMileageMeters = const Value.absent(),
                Value<bool> retired = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoesCompanion(
                id: id,
                name: name,
                brand: brand,
                model: model,
                initialMileageMeters: initialMileageMeters,
                targetMileageMeters: targetMileageMeters,
                retired: retired,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<double> initialMileageMeters = const Value.absent(),
                Value<double?> targetMileageMeters = const Value.absent(),
                Value<bool> retired = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoesCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                model: model,
                initialMileageMeters: initialMileageMeters,
                targetMileageMeters: targetMileageMeters,
                retired: retired,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoesTable,
      ShoeData,
      $$ShoesTableFilterComposer,
      $$ShoesTableOrderingComposer,
      $$ShoesTableAnnotationComposer,
      $$ShoesTableCreateCompanionBuilder,
      $$ShoesTableUpdateCompanionBuilder,
      (ShoeData, BaseReferences<_$AppDatabase, $ShoesTable, ShoeData>),
      ShoeData,
      PrefetchHooks Function()
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      required String id,
      required String distanceKey,
      required String runId,
      required int timeSeconds,
      required double paceSecondsPerKm,
      required DateTime achievedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<String> id,
      Value<String> distanceKey,
      Value<String> runId,
      Value<int> timeSeconds,
      Value<double> paceSecondsPerKm,
      Value<DateTime> achievedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceKey => $composableBuilder(
    column: $table.distanceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paceSecondsPerKm => $composableBuilder(
    column: $table.paceSecondsPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceKey => $composableBuilder(
    column: $table.distanceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paceSecondsPerKm => $composableBuilder(
    column: $table.paceSecondsPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get distanceKey => $composableBuilder(
    column: $table.distanceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get paceSecondsPerKm => $composableBuilder(
    column: $table.paceSecondsPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordData,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (
            PersonalRecordData,
            BaseReferences<
              _$AppDatabase,
              $PersonalRecordsTable,
              PersonalRecordData
            >,
          ),
          PersonalRecordData,
          PrefetchHooks Function()
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> distanceKey = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<int> timeSeconds = const Value.absent(),
                Value<double> paceSecondsPerKm = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                distanceKey: distanceKey,
                runId: runId,
                timeSeconds: timeSeconds,
                paceSecondsPerKm: paceSecondsPerKm,
                achievedAt: achievedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String distanceKey,
                required String runId,
                required int timeSeconds,
                required double paceSecondsPerKm,
                required DateTime achievedAt,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                id: id,
                distanceKey: distanceKey,
                runId: runId,
                timeSeconds: timeSeconds,
                paceSecondsPerKm: paceSecondsPerKm,
                achievedAt: achievedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecordData,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (
        PersonalRecordData,
        BaseReferences<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordData
        >,
      ),
      PersonalRecordData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$ShoesTableTableManager get shoes =>
      $$ShoesTableTableManager(_db, _db.shoes);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
}
