// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
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
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineCcMeta = const VerificationMeta(
    'engineCc',
  );
  @override
  late final GeneratedColumn<int> engineCc = GeneratedColumn<int>(
    'engine_cc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationNoMeta = const VerificationMeta(
    'registrationNo',
  );
  @override
  late final GeneratedColumn<String> registrationNo = GeneratedColumn<String>(
    'registration_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType, String> fuelType =
      GeneratedColumn<String>(
        'fuel_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('petrol'),
      ).withConverter<FuelType>($VehiclesTable.$converterfuelType);
  static const VerificationMeta _purchaseDateMsMeta = const VerificationMeta(
    'purchaseDateMs',
  );
  @override
  late final GeneratedColumn<int> purchaseDateMs = GeneratedColumn<int>(
    'purchase_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMinorMeta =
      const VerificationMeta('purchasePriceMinor');
  @override
  late final GeneratedColumn<int> purchasePriceMinor = GeneratedColumn<int>(
    'purchase_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialOdometerMMeta = const VerificationMeta(
    'initialOdometerM',
  );
  @override
  late final GeneratedColumn<int> initialOdometerM = GeneratedColumn<int>(
    'initial_odometer_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentValueEstimateMinorMeta =
      const VerificationMeta('currentValueEstimateMinor');
  @override
  late final GeneratedColumn<int> currentValueEstimateMinor =
      GeneratedColumn<int>(
        'current_value_estimate_minor',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tankCapacityMlMeta = const VerificationMeta(
    'tankCapacityMl',
  );
  @override
  late final GeneratedColumn<int> tankCapacityMl = GeneratedColumn<int>(
    'tank_capacity_ml',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DistanceUnit, String>
  distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('km'),
  ).withConverter<DistanceUnit>($VehiclesTable.$converterdistanceUnit);
  @override
  late final GeneratedColumnWithTypeConverter<VolumeUnit, String> volumeUnit =
      GeneratedColumn<String>(
        'volume_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('l'),
      ).withConverter<VolumeUnit>($VehiclesTable.$convertervolumeUnit);
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorTagMeta = const VerificationMeta(
    'colorTag',
  );
  @override
  late final GeneratedColumn<int> colorTag = GeneratedColumn<int>(
    'color_tag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    make,
    model,
    year,
    engineCc,
    registrationNo,
    fuelType,
    purchaseDateMs,
    purchasePriceMinor,
    initialOdometerM,
    currentValueEstimateMinor,
    tankCapacityMl,
    distanceUnit,
    volumeUnit,
    currency,
    isDefault,
    colorTag,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('engine_cc')) {
      context.handle(
        _engineCcMeta,
        engineCc.isAcceptableOrUnknown(data['engine_cc']!, _engineCcMeta),
      );
    }
    if (data.containsKey('registration_no')) {
      context.handle(
        _registrationNoMeta,
        registrationNo.isAcceptableOrUnknown(
          data['registration_no']!,
          _registrationNoMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date_ms')) {
      context.handle(
        _purchaseDateMsMeta,
        purchaseDateMs.isAcceptableOrUnknown(
          data['purchase_date_ms']!,
          _purchaseDateMsMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price_minor')) {
      context.handle(
        _purchasePriceMinorMeta,
        purchasePriceMinor.isAcceptableOrUnknown(
          data['purchase_price_minor']!,
          _purchasePriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('initial_odometer_m')) {
      context.handle(
        _initialOdometerMMeta,
        initialOdometerM.isAcceptableOrUnknown(
          data['initial_odometer_m']!,
          _initialOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('current_value_estimate_minor')) {
      context.handle(
        _currentValueEstimateMinorMeta,
        currentValueEstimateMinor.isAcceptableOrUnknown(
          data['current_value_estimate_minor']!,
          _currentValueEstimateMinorMeta,
        ),
      );
    }
    if (data.containsKey('tank_capacity_ml')) {
      context.handle(
        _tankCapacityMlMeta,
        tankCapacityMl.isAcceptableOrUnknown(
          data['tank_capacity_ml']!,
          _tankCapacityMlMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('color_tag')) {
      context.handle(
        _colorTagMeta,
        colorTag.isAcceptableOrUnknown(data['color_tag']!, _colorTagMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      engineCc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}engine_cc'],
      ),
      registrationNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_no'],
      ),
      fuelType: $VehiclesTable.$converterfuelType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fuel_type'],
        )!,
      ),
      purchaseDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_date_ms'],
      ),
      purchasePriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price_minor'],
      ),
      initialOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_odometer_m'],
      )!,
      currentValueEstimateMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_value_estimate_minor'],
      ),
      tankCapacityMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tank_capacity_ml'],
      ),
      distanceUnit: $VehiclesTable.$converterdistanceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_unit'],
        )!,
      ),
      volumeUnit: $VehiclesTable.$convertervolumeUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}volume_unit'],
        )!,
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      colorTag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_tag'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FuelType, String, String> $converterfuelType =
      const EnumNameConverter<FuelType>(FuelType.values);
  static JsonTypeConverter2<DistanceUnit, String, String>
  $converterdistanceUnit = const EnumNameConverter<DistanceUnit>(
    DistanceUnit.values,
  );
  static JsonTypeConverter2<VolumeUnit, String, String> $convertervolumeUnit =
      const EnumNameConverter<VolumeUnit>(VolumeUnit.values);
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String name;
  final String? make;
  final String? model;
  final int? year;
  final int? engineCc;
  final String? registrationNo;
  final FuelType fuelType;
  final int? purchaseDateMs;

  /// Minor units (paisa).
  final int? purchasePriceMinor;

  /// Odometer reading when the bike entered the log, in metres. Distance
  /// owned is measured from here, not from zero — most people start logging
  /// on a bike that already has kilometres on it.
  final int initialOdometerM;

  /// What the bike is worth now, in minor units. Drives the depreciation
  /// half of true cost/km. Null ⇒ fall back to the default annual rate.
  final int? currentValueEstimateMinor;
  final int? tankCapacityMl;
  final DistanceUnit distanceUnit;
  final VolumeUnit volumeUnit;
  final String currency;
  final bool isDefault;

  /// Index into `Palette.vehicleTags`.
  final int colorTag;

  /// Archived bikes stay in the data (their history still counts in
  /// all-vehicle stats) but drop out of the switcher.
  final bool isArchived;
  const VehicleRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.make,
    this.model,
    this.year,
    this.engineCc,
    this.registrationNo,
    required this.fuelType,
    this.purchaseDateMs,
    this.purchasePriceMinor,
    required this.initialOdometerM,
    this.currentValueEstimateMinor,
    this.tankCapacityMl,
    required this.distanceUnit,
    required this.volumeUnit,
    required this.currency,
    required this.isDefault,
    required this.colorTag,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || make != null) {
      map['make'] = Variable<String>(make);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || engineCc != null) {
      map['engine_cc'] = Variable<int>(engineCc);
    }
    if (!nullToAbsent || registrationNo != null) {
      map['registration_no'] = Variable<String>(registrationNo);
    }
    {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType),
      );
    }
    if (!nullToAbsent || purchaseDateMs != null) {
      map['purchase_date_ms'] = Variable<int>(purchaseDateMs);
    }
    if (!nullToAbsent || purchasePriceMinor != null) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor);
    }
    map['initial_odometer_m'] = Variable<int>(initialOdometerM);
    if (!nullToAbsent || currentValueEstimateMinor != null) {
      map['current_value_estimate_minor'] = Variable<int>(
        currentValueEstimateMinor,
      );
    }
    if (!nullToAbsent || tankCapacityMl != null) {
      map['tank_capacity_ml'] = Variable<int>(tankCapacityMl);
    }
    {
      map['distance_unit'] = Variable<String>(
        $VehiclesTable.$converterdistanceUnit.toSql(distanceUnit),
      );
    }
    {
      map['volume_unit'] = Variable<String>(
        $VehiclesTable.$convertervolumeUnit.toSql(volumeUnit),
      );
    }
    map['currency'] = Variable<String>(currency);
    map['is_default'] = Variable<bool>(isDefault);
    map['color_tag'] = Variable<int>(colorTag);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      make: make == null && nullToAbsent ? const Value.absent() : Value(make),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      engineCc: engineCc == null && nullToAbsent
          ? const Value.absent()
          : Value(engineCc),
      registrationNo: registrationNo == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNo),
      fuelType: Value(fuelType),
      purchaseDateMs: purchaseDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDateMs),
      purchasePriceMinor: purchasePriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePriceMinor),
      initialOdometerM: Value(initialOdometerM),
      currentValueEstimateMinor:
          currentValueEstimateMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(currentValueEstimateMinor),
      tankCapacityMl: tankCapacityMl == null && nullToAbsent
          ? const Value.absent()
          : Value(tankCapacityMl),
      distanceUnit: Value(distanceUnit),
      volumeUnit: Value(volumeUnit),
      currency: Value(currency),
      isDefault: Value(isDefault),
      colorTag: Value(colorTag),
      isArchived: Value(isArchived),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      make: serializer.fromJson<String?>(json['make']),
      model: serializer.fromJson<String?>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      engineCc: serializer.fromJson<int?>(json['engineCc']),
      registrationNo: serializer.fromJson<String?>(json['registrationNo']),
      fuelType: $VehiclesTable.$converterfuelType.fromJson(
        serializer.fromJson<String>(json['fuelType']),
      ),
      purchaseDateMs: serializer.fromJson<int?>(json['purchaseDateMs']),
      purchasePriceMinor: serializer.fromJson<int?>(json['purchasePriceMinor']),
      initialOdometerM: serializer.fromJson<int>(json['initialOdometerM']),
      currentValueEstimateMinor: serializer.fromJson<int?>(
        json['currentValueEstimateMinor'],
      ),
      tankCapacityMl: serializer.fromJson<int?>(json['tankCapacityMl']),
      distanceUnit: $VehiclesTable.$converterdistanceUnit.fromJson(
        serializer.fromJson<String>(json['distanceUnit']),
      ),
      volumeUnit: $VehiclesTable.$convertervolumeUnit.fromJson(
        serializer.fromJson<String>(json['volumeUnit']),
      ),
      currency: serializer.fromJson<String>(json['currency']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      colorTag: serializer.fromJson<int>(json['colorTag']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'make': serializer.toJson<String?>(make),
      'model': serializer.toJson<String?>(model),
      'year': serializer.toJson<int?>(year),
      'engineCc': serializer.toJson<int?>(engineCc),
      'registrationNo': serializer.toJson<String?>(registrationNo),
      'fuelType': serializer.toJson<String>(
        $VehiclesTable.$converterfuelType.toJson(fuelType),
      ),
      'purchaseDateMs': serializer.toJson<int?>(purchaseDateMs),
      'purchasePriceMinor': serializer.toJson<int?>(purchasePriceMinor),
      'initialOdometerM': serializer.toJson<int>(initialOdometerM),
      'currentValueEstimateMinor': serializer.toJson<int?>(
        currentValueEstimateMinor,
      ),
      'tankCapacityMl': serializer.toJson<int?>(tankCapacityMl),
      'distanceUnit': serializer.toJson<String>(
        $VehiclesTable.$converterdistanceUnit.toJson(distanceUnit),
      ),
      'volumeUnit': serializer.toJson<String>(
        $VehiclesTable.$convertervolumeUnit.toJson(volumeUnit),
      ),
      'currency': serializer.toJson<String>(currency),
      'isDefault': serializer.toJson<bool>(isDefault),
      'colorTag': serializer.toJson<int>(colorTag),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  VehicleRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> make = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<int?> engineCc = const Value.absent(),
    Value<String?> registrationNo = const Value.absent(),
    FuelType? fuelType,
    Value<int?> purchaseDateMs = const Value.absent(),
    Value<int?> purchasePriceMinor = const Value.absent(),
    int? initialOdometerM,
    Value<int?> currentValueEstimateMinor = const Value.absent(),
    Value<int?> tankCapacityMl = const Value.absent(),
    DistanceUnit? distanceUnit,
    VolumeUnit? volumeUnit,
    String? currency,
    bool? isDefault,
    int? colorTag,
    bool? isArchived,
  }) => VehicleRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    make: make.present ? make.value : this.make,
    model: model.present ? model.value : this.model,
    year: year.present ? year.value : this.year,
    engineCc: engineCc.present ? engineCc.value : this.engineCc,
    registrationNo: registrationNo.present
        ? registrationNo.value
        : this.registrationNo,
    fuelType: fuelType ?? this.fuelType,
    purchaseDateMs: purchaseDateMs.present
        ? purchaseDateMs.value
        : this.purchaseDateMs,
    purchasePriceMinor: purchasePriceMinor.present
        ? purchasePriceMinor.value
        : this.purchasePriceMinor,
    initialOdometerM: initialOdometerM ?? this.initialOdometerM,
    currentValueEstimateMinor: currentValueEstimateMinor.present
        ? currentValueEstimateMinor.value
        : this.currentValueEstimateMinor,
    tankCapacityMl: tankCapacityMl.present
        ? tankCapacityMl.value
        : this.tankCapacityMl,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    volumeUnit: volumeUnit ?? this.volumeUnit,
    currency: currency ?? this.currency,
    isDefault: isDefault ?? this.isDefault,
    colorTag: colorTag ?? this.colorTag,
    isArchived: isArchived ?? this.isArchived,
  );
  VehicleRow copyWithCompanion(VehiclesCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      engineCc: data.engineCc.present ? data.engineCc.value : this.engineCc,
      registrationNo: data.registrationNo.present
          ? data.registrationNo.value
          : this.registrationNo,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      purchaseDateMs: data.purchaseDateMs.present
          ? data.purchaseDateMs.value
          : this.purchaseDateMs,
      purchasePriceMinor: data.purchasePriceMinor.present
          ? data.purchasePriceMinor.value
          : this.purchasePriceMinor,
      initialOdometerM: data.initialOdometerM.present
          ? data.initialOdometerM.value
          : this.initialOdometerM,
      currentValueEstimateMinor: data.currentValueEstimateMinor.present
          ? data.currentValueEstimateMinor.value
          : this.currentValueEstimateMinor,
      tankCapacityMl: data.tankCapacityMl.present
          ? data.tankCapacityMl.value
          : this.tankCapacityMl,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      volumeUnit: data.volumeUnit.present
          ? data.volumeUnit.value
          : this.volumeUnit,
      currency: data.currency.present ? data.currency.value : this.currency,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      colorTag: data.colorTag.present ? data.colorTag.value : this.colorTag,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('engineCc: $engineCc, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('fuelType: $fuelType, ')
          ..write('purchaseDateMs: $purchaseDateMs, ')
          ..write('purchasePriceMinor: $purchasePriceMinor, ')
          ..write('initialOdometerM: $initialOdometerM, ')
          ..write('currentValueEstimateMinor: $currentValueEstimateMinor, ')
          ..write('tankCapacityMl: $tankCapacityMl, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('currency: $currency, ')
          ..write('isDefault: $isDefault, ')
          ..write('colorTag: $colorTag, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    make,
    model,
    year,
    engineCc,
    registrationNo,
    fuelType,
    purchaseDateMs,
    purchasePriceMinor,
    initialOdometerM,
    currentValueEstimateMinor,
    tankCapacityMl,
    distanceUnit,
    volumeUnit,
    currency,
    isDefault,
    colorTag,
    isArchived,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.engineCc == this.engineCc &&
          other.registrationNo == this.registrationNo &&
          other.fuelType == this.fuelType &&
          other.purchaseDateMs == this.purchaseDateMs &&
          other.purchasePriceMinor == this.purchasePriceMinor &&
          other.initialOdometerM == this.initialOdometerM &&
          other.currentValueEstimateMinor == this.currentValueEstimateMinor &&
          other.tankCapacityMl == this.tankCapacityMl &&
          other.distanceUnit == this.distanceUnit &&
          other.volumeUnit == this.volumeUnit &&
          other.currency == this.currency &&
          other.isDefault == this.isDefault &&
          other.colorTag == this.colorTag &&
          other.isArchived == this.isArchived);
}

class VehiclesCompanion extends UpdateCompanion<VehicleRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<String?> make;
  final Value<String?> model;
  final Value<int?> year;
  final Value<int?> engineCc;
  final Value<String?> registrationNo;
  final Value<FuelType> fuelType;
  final Value<int?> purchaseDateMs;
  final Value<int?> purchasePriceMinor;
  final Value<int> initialOdometerM;
  final Value<int?> currentValueEstimateMinor;
  final Value<int?> tankCapacityMl;
  final Value<DistanceUnit> distanceUnit;
  final Value<VolumeUnit> volumeUnit;
  final Value<String> currency;
  final Value<bool> isDefault;
  final Value<int> colorTag;
  final Value<bool> isArchived;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.engineCc = const Value.absent(),
    this.registrationNo = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.purchaseDateMs = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
    this.initialOdometerM = const Value.absent(),
    this.currentValueEstimateMinor = const Value.absent(),
    this.tankCapacityMl = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.volumeUnit = const Value.absent(),
    this.currency = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.engineCc = const Value.absent(),
    this.registrationNo = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.purchaseDateMs = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
    this.initialOdometerM = const Value.absent(),
    this.currentValueEstimateMinor = const Value.absent(),
    this.tankCapacityMl = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.volumeUnit = const Value.absent(),
    this.currency = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<VehicleRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<int>? engineCc,
    Expression<String>? registrationNo,
    Expression<String>? fuelType,
    Expression<int>? purchaseDateMs,
    Expression<int>? purchasePriceMinor,
    Expression<int>? initialOdometerM,
    Expression<int>? currentValueEstimateMinor,
    Expression<int>? tankCapacityMl,
    Expression<String>? distanceUnit,
    Expression<String>? volumeUnit,
    Expression<String>? currency,
    Expression<bool>? isDefault,
    Expression<int>? colorTag,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (engineCc != null) 'engine_cc': engineCc,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (fuelType != null) 'fuel_type': fuelType,
      if (purchaseDateMs != null) 'purchase_date_ms': purchaseDateMs,
      if (purchasePriceMinor != null)
        'purchase_price_minor': purchasePriceMinor,
      if (initialOdometerM != null) 'initial_odometer_m': initialOdometerM,
      if (currentValueEstimateMinor != null)
        'current_value_estimate_minor': currentValueEstimateMinor,
      if (tankCapacityMl != null) 'tank_capacity_ml': tankCapacityMl,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (volumeUnit != null) 'volume_unit': volumeUnit,
      if (currency != null) 'currency': currency,
      if (isDefault != null) 'is_default': isDefault,
      if (colorTag != null) 'color_tag': colorTag,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<String?>? make,
    Value<String?>? model,
    Value<int?>? year,
    Value<int?>? engineCc,
    Value<String?>? registrationNo,
    Value<FuelType>? fuelType,
    Value<int?>? purchaseDateMs,
    Value<int?>? purchasePriceMinor,
    Value<int>? initialOdometerM,
    Value<int?>? currentValueEstimateMinor,
    Value<int?>? tankCapacityMl,
    Value<DistanceUnit>? distanceUnit,
    Value<VolumeUnit>? volumeUnit,
    Value<String>? currency,
    Value<bool>? isDefault,
    Value<int>? colorTag,
    Value<bool>? isArchived,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      engineCc: engineCc ?? this.engineCc,
      registrationNo: registrationNo ?? this.registrationNo,
      fuelType: fuelType ?? this.fuelType,
      purchaseDateMs: purchaseDateMs ?? this.purchaseDateMs,
      purchasePriceMinor: purchasePriceMinor ?? this.purchasePriceMinor,
      initialOdometerM: initialOdometerM ?? this.initialOdometerM,
      currentValueEstimateMinor:
          currentValueEstimateMinor ?? this.currentValueEstimateMinor,
      tankCapacityMl: tankCapacityMl ?? this.tankCapacityMl,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      colorTag: colorTag ?? this.colorTag,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (engineCc.present) {
      map['engine_cc'] = Variable<int>(engineCc.value);
    }
    if (registrationNo.present) {
      map['registration_no'] = Variable<String>(registrationNo.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType.value),
      );
    }
    if (purchaseDateMs.present) {
      map['purchase_date_ms'] = Variable<int>(purchaseDateMs.value);
    }
    if (purchasePriceMinor.present) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor.value);
    }
    if (initialOdometerM.present) {
      map['initial_odometer_m'] = Variable<int>(initialOdometerM.value);
    }
    if (currentValueEstimateMinor.present) {
      map['current_value_estimate_minor'] = Variable<int>(
        currentValueEstimateMinor.value,
      );
    }
    if (tankCapacityMl.present) {
      map['tank_capacity_ml'] = Variable<int>(tankCapacityMl.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
        $VehiclesTable.$converterdistanceUnit.toSql(distanceUnit.value),
      );
    }
    if (volumeUnit.present) {
      map['volume_unit'] = Variable<String>(
        $VehiclesTable.$convertervolumeUnit.toSql(volumeUnit.value),
      );
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (colorTag.present) {
      map['color_tag'] = Variable<int>(colorTag.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('engineCc: $engineCc, ')
          ..write('registrationNo: $registrationNo, ')
          ..write('fuelType: $fuelType, ')
          ..write('purchaseDateMs: $purchaseDateMs, ')
          ..write('purchasePriceMinor: $purchasePriceMinor, ')
          ..write('initialOdometerM: $initialOdometerM, ')
          ..write('currentValueEstimateMinor: $currentValueEstimateMinor, ')
          ..write('tankCapacityMl: $tankCapacityMl, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('volumeUnit: $volumeUnit, ')
          ..write('currency: $currency, ')
          ..write('isDefault: $isDefault, ')
          ..write('colorTag: $colorTag, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $FuelEntriesTable extends FuelEntries
    with TableInfo<$FuelEntriesTable, FuelEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMsMeta = const VerificationMeta('dateMs');
  @override
  late final GeneratedColumn<int> dateMs = GeneratedColumn<int>(
    'date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerMMeta = const VerificationMeta(
    'odometerM',
  );
  @override
  late final GeneratedColumn<int> odometerM = GeneratedColumn<int>(
    'odometer_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMlMeta = const VerificationMeta(
    'volumeMl',
  );
  @override
  late final GeneratedColumn<int> volumeMl = GeneratedColumn<int>(
    'volume_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUnitMinorMeta = const VerificationMeta(
    'pricePerUnitMinor',
  );
  @override
  late final GeneratedColumn<int> pricePerUnitMinor = GeneratedColumn<int>(
    'price_per_unit_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostMinorMeta = const VerificationMeta(
    'totalCostMinor',
  );
  @override
  late final GeneratedColumn<int> totalCostMinor = GeneratedColumn<int>(
    'total_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFullTankMeta = const VerificationMeta(
    'isFullTank',
  );
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
    'is_full_tank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full_tank" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isMissedEntryMeta = const VerificationMeta(
    'isMissedEntry',
  );
  @override
  late final GeneratedColumn<bool> isMissedEntry = GeneratedColumn<bool>(
    'is_missed_entry',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_missed_entry" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stationMeta = const VerificationMeta(
    'station',
  );
  @override
  late final GeneratedColumn<String> station = GeneratedColumn<String>(
    'station',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    dateMs,
    odometerM,
    volumeMl,
    pricePerUnitMinor,
    totalCostMinor,
    isFullTank,
    isMissedEntry,
    station,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date_ms')) {
      context.handle(
        _dateMsMeta,
        dateMs.isAcceptableOrUnknown(data['date_ms']!, _dateMsMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMsMeta);
    }
    if (data.containsKey('odometer_m')) {
      context.handle(
        _odometerMMeta,
        odometerM.isAcceptableOrUnknown(data['odometer_m']!, _odometerMMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerMMeta);
    }
    if (data.containsKey('volume_ml')) {
      context.handle(
        _volumeMlMeta,
        volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMlMeta);
    }
    if (data.containsKey('price_per_unit_minor')) {
      context.handle(
        _pricePerUnitMinorMeta,
        pricePerUnitMinor.isAcceptableOrUnknown(
          data['price_per_unit_minor']!,
          _pricePerUnitMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUnitMinorMeta);
    }
    if (data.containsKey('total_cost_minor')) {
      context.handle(
        _totalCostMinorMeta,
        totalCostMinor.isAcceptableOrUnknown(
          data['total_cost_minor']!,
          _totalCostMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostMinorMeta);
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
        _isFullTankMeta,
        isFullTank.isAcceptableOrUnknown(
          data['is_full_tank']!,
          _isFullTankMeta,
        ),
      );
    }
    if (data.containsKey('is_missed_entry')) {
      context.handle(
        _isMissedEntryMeta,
        isMissedEntry.isAcceptableOrUnknown(
          data['is_missed_entry']!,
          _isMissedEntryMeta,
        ),
      );
    }
    if (data.containsKey('station')) {
      context.handle(
        _stationMeta,
        station.isAcceptableOrUnknown(data['station']!, _stationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      dateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_ms'],
      )!,
      odometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_m'],
      )!,
      volumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_ml'],
      )!,
      pricePerUnitMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_unit_minor'],
      )!,
      totalCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_minor'],
      )!,
      isFullTank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full_tank'],
      )!,
      isMissedEntry: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_missed_entry'],
      )!,
      station: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $FuelEntriesTable createAlias(String alias) {
    return $FuelEntriesTable(attachedDatabase, alias);
  }
}

class FuelEntryRow extends DataClass implements Insertable<FuelEntryRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final int dateMs;
  final int odometerM;
  final int volumeMl;

  /// Price per litre in minor units. Kept alongside [totalCostMinor] rather
  /// than derived, because the user may have typed either one.
  final int pricePerUnitMinor;
  final int totalCostMinor;

  /// Only full-tank-to-full-tank spans produce a mileage figure. A partial
  /// fill contributes its volume to the *next* full tank's window.
  final bool isFullTank;

  /// The user knows they skipped logging a fill somewhere before this one.
  /// Poisons the whole window it lands in — that window is shown but never
  /// averaged.
  final bool isMissedEntry;
  final String? station;
  final String? notes;
  const FuelEntryRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    required this.dateMs,
    required this.odometerM,
    required this.volumeMl,
    required this.pricePerUnitMinor,
    required this.totalCostMinor,
    required this.isFullTank,
    required this.isMissedEntry,
    this.station,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['date_ms'] = Variable<int>(dateMs);
    map['odometer_m'] = Variable<int>(odometerM);
    map['volume_ml'] = Variable<int>(volumeMl);
    map['price_per_unit_minor'] = Variable<int>(pricePerUnitMinor);
    map['total_cost_minor'] = Variable<int>(totalCostMinor);
    map['is_full_tank'] = Variable<bool>(isFullTank);
    map['is_missed_entry'] = Variable<bool>(isMissedEntry);
    if (!nullToAbsent || station != null) {
      map['station'] = Variable<String>(station);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  FuelEntriesCompanion toCompanion(bool nullToAbsent) {
    return FuelEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      dateMs: Value(dateMs),
      odometerM: Value(odometerM),
      volumeMl: Value(volumeMl),
      pricePerUnitMinor: Value(pricePerUnitMinor),
      totalCostMinor: Value(totalCostMinor),
      isFullTank: Value(isFullTank),
      isMissedEntry: Value(isMissedEntry),
      station: station == null && nullToAbsent
          ? const Value.absent()
          : Value(station),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory FuelEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelEntryRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      dateMs: serializer.fromJson<int>(json['dateMs']),
      odometerM: serializer.fromJson<int>(json['odometerM']),
      volumeMl: serializer.fromJson<int>(json['volumeMl']),
      pricePerUnitMinor: serializer.fromJson<int>(json['pricePerUnitMinor']),
      totalCostMinor: serializer.fromJson<int>(json['totalCostMinor']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
      isMissedEntry: serializer.fromJson<bool>(json['isMissedEntry']),
      station: serializer.fromJson<String?>(json['station']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'dateMs': serializer.toJson<int>(dateMs),
      'odometerM': serializer.toJson<int>(odometerM),
      'volumeMl': serializer.toJson<int>(volumeMl),
      'pricePerUnitMinor': serializer.toJson<int>(pricePerUnitMinor),
      'totalCostMinor': serializer.toJson<int>(totalCostMinor),
      'isFullTank': serializer.toJson<bool>(isFullTank),
      'isMissedEntry': serializer.toJson<bool>(isMissedEntry),
      'station': serializer.toJson<String?>(station),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  FuelEntryRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    int? dateMs,
    int? odometerM,
    int? volumeMl,
    int? pricePerUnitMinor,
    int? totalCostMinor,
    bool? isFullTank,
    bool? isMissedEntry,
    Value<String?> station = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => FuelEntryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    dateMs: dateMs ?? this.dateMs,
    odometerM: odometerM ?? this.odometerM,
    volumeMl: volumeMl ?? this.volumeMl,
    pricePerUnitMinor: pricePerUnitMinor ?? this.pricePerUnitMinor,
    totalCostMinor: totalCostMinor ?? this.totalCostMinor,
    isFullTank: isFullTank ?? this.isFullTank,
    isMissedEntry: isMissedEntry ?? this.isMissedEntry,
    station: station.present ? station.value : this.station,
    notes: notes.present ? notes.value : this.notes,
  );
  FuelEntryRow copyWithCompanion(FuelEntriesCompanion data) {
    return FuelEntryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      dateMs: data.dateMs.present ? data.dateMs.value : this.dateMs,
      odometerM: data.odometerM.present ? data.odometerM.value : this.odometerM,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      pricePerUnitMinor: data.pricePerUnitMinor.present
          ? data.pricePerUnitMinor.value
          : this.pricePerUnitMinor,
      totalCostMinor: data.totalCostMinor.present
          ? data.totalCostMinor.value
          : this.totalCostMinor,
      isFullTank: data.isFullTank.present
          ? data.isFullTank.value
          : this.isFullTank,
      isMissedEntry: data.isMissedEntry.present
          ? data.isMissedEntry.value
          : this.isMissedEntry,
      station: data.station.present ? data.station.value : this.station,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dateMs: $dateMs, ')
          ..write('odometerM: $odometerM, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('pricePerUnitMinor: $pricePerUnitMinor, ')
          ..write('totalCostMinor: $totalCostMinor, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isMissedEntry: $isMissedEntry, ')
          ..write('station: $station, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    dateMs,
    odometerM,
    volumeMl,
    pricePerUnitMinor,
    totalCostMinor,
    isFullTank,
    isMissedEntry,
    station,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelEntryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.dateMs == this.dateMs &&
          other.odometerM == this.odometerM &&
          other.volumeMl == this.volumeMl &&
          other.pricePerUnitMinor == this.pricePerUnitMinor &&
          other.totalCostMinor == this.totalCostMinor &&
          other.isFullTank == this.isFullTank &&
          other.isMissedEntry == this.isMissedEntry &&
          other.station == this.station &&
          other.notes == this.notes);
}

class FuelEntriesCompanion extends UpdateCompanion<FuelEntryRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<int> dateMs;
  final Value<int> odometerM;
  final Value<int> volumeMl;
  final Value<int> pricePerUnitMinor;
  final Value<int> totalCostMinor;
  final Value<bool> isFullTank;
  final Value<bool> isMissedEntry;
  final Value<String?> station;
  final Value<String?> notes;
  const FuelEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.dateMs = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.pricePerUnitMinor = const Value.absent(),
    this.totalCostMinor = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.isMissedEntry = const Value.absent(),
    this.station = const Value.absent(),
    this.notes = const Value.absent(),
  });
  FuelEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    required int dateMs,
    required int odometerM,
    required int volumeMl,
    required int pricePerUnitMinor,
    required int totalCostMinor,
    this.isFullTank = const Value.absent(),
    this.isMissedEntry = const Value.absent(),
    this.station = const Value.absent(),
    this.notes = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       dateMs = Value(dateMs),
       odometerM = Value(odometerM),
       volumeMl = Value(volumeMl),
       pricePerUnitMinor = Value(pricePerUnitMinor),
       totalCostMinor = Value(totalCostMinor);
  static Insertable<FuelEntryRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<int>? dateMs,
    Expression<int>? odometerM,
    Expression<int>? volumeMl,
    Expression<int>? pricePerUnitMinor,
    Expression<int>? totalCostMinor,
    Expression<bool>? isFullTank,
    Expression<bool>? isMissedEntry,
    Expression<String>? station,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (dateMs != null) 'date_ms': dateMs,
      if (odometerM != null) 'odometer_m': odometerM,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (pricePerUnitMinor != null) 'price_per_unit_minor': pricePerUnitMinor,
      if (totalCostMinor != null) 'total_cost_minor': totalCostMinor,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (isMissedEntry != null) 'is_missed_entry': isMissedEntry,
      if (station != null) 'station': station,
      if (notes != null) 'notes': notes,
    });
  }

  FuelEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<int>? dateMs,
    Value<int>? odometerM,
    Value<int>? volumeMl,
    Value<int>? pricePerUnitMinor,
    Value<int>? totalCostMinor,
    Value<bool>? isFullTank,
    Value<bool>? isMissedEntry,
    Value<String?>? station,
    Value<String?>? notes,
  }) {
    return FuelEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      dateMs: dateMs ?? this.dateMs,
      odometerM: odometerM ?? this.odometerM,
      volumeMl: volumeMl ?? this.volumeMl,
      pricePerUnitMinor: pricePerUnitMinor ?? this.pricePerUnitMinor,
      totalCostMinor: totalCostMinor ?? this.totalCostMinor,
      isFullTank: isFullTank ?? this.isFullTank,
      isMissedEntry: isMissedEntry ?? this.isMissedEntry,
      station: station ?? this.station,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (dateMs.present) {
      map['date_ms'] = Variable<int>(dateMs.value);
    }
    if (odometerM.present) {
      map['odometer_m'] = Variable<int>(odometerM.value);
    }
    if (volumeMl.present) {
      map['volume_ml'] = Variable<int>(volumeMl.value);
    }
    if (pricePerUnitMinor.present) {
      map['price_per_unit_minor'] = Variable<int>(pricePerUnitMinor.value);
    }
    if (totalCostMinor.present) {
      map['total_cost_minor'] = Variable<int>(totalCostMinor.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    if (isMissedEntry.present) {
      map['is_missed_entry'] = Variable<bool>(isMissedEntry.value);
    }
    if (station.present) {
      map['station'] = Variable<String>(station.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('dateMs: $dateMs, ')
          ..write('odometerM: $odometerM, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('pricePerUnitMinor: $pricePerUnitMinor, ')
          ..write('totalCostMinor: $totalCostMinor, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isMissedEntry: $isMissedEntry, ')
          ..write('station: $station, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ServiceItemsTable extends ServiceItems
    with TableInfo<$ServiceItemsTable, ServiceItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMMeta = const VerificationMeta(
    'intervalM',
  );
  @override
  late final GeneratedColumn<int> intervalM = GeneratedColumn<int>(
    'interval_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDoneOdometerMMeta = const VerificationMeta(
    'lastDoneOdometerM',
  );
  @override
  late final GeneratedColumn<int> lastDoneOdometerM = GeneratedColumn<int>(
    'last_done_odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDoneDateMsMeta = const VerificationMeta(
    'lastDoneDateMs',
  );
  @override
  late final GeneratedColumn<int> lastDoneDateMs = GeneratedColumn<int>(
    'last_done_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wrench'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    name,
    intervalM,
    intervalDays,
    lastDoneOdometerM,
    lastDoneDateMs,
    isActive,
    iconKey,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('interval_m')) {
      context.handle(
        _intervalMMeta,
        intervalM.isAcceptableOrUnknown(data['interval_m']!, _intervalMMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_done_odometer_m')) {
      context.handle(
        _lastDoneOdometerMMeta,
        lastDoneOdometerM.isAcceptableOrUnknown(
          data['last_done_odometer_m']!,
          _lastDoneOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('last_done_date_ms')) {
      context.handle(
        _lastDoneDateMsMeta,
        lastDoneDateMs.isAcceptableOrUnknown(
          data['last_done_date_ms']!,
          _lastDoneDateMsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      intervalM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_m'],
      ),
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      lastDoneOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_done_odometer_m'],
      ),
      lastDoneDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_done_date_ms'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ServiceItemsTable createAlias(String alias) {
    return $ServiceItemsTable(attachedDatabase, alias);
  }
}

class ServiceItemRow extends DataClass implements Insertable<ServiceItemRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final String name;

  /// Interval in metres. Either or both intervals may be set; whichever
  /// comes first wins. Both null ⇒ the item is informational only.
  final int? intervalM;
  final int? intervalDays;
  final int? lastDoneOdometerM;
  final int? lastDoneDateMs;
  final bool isActive;

  /// Stable key into the icon map, so icons survive a rename.
  final String iconKey;
  final int sortOrder;
  const ServiceItemRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    required this.name,
    this.intervalM,
    this.intervalDays,
    this.lastDoneOdometerM,
    this.lastDoneDateMs,
    required this.isActive,
    required this.iconKey,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || intervalM != null) {
      map['interval_m'] = Variable<int>(intervalM);
    }
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || lastDoneOdometerM != null) {
      map['last_done_odometer_m'] = Variable<int>(lastDoneOdometerM);
    }
    if (!nullToAbsent || lastDoneDateMs != null) {
      map['last_done_date_ms'] = Variable<int>(lastDoneDateMs);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['icon_key'] = Variable<String>(iconKey);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ServiceItemsCompanion toCompanion(bool nullToAbsent) {
    return ServiceItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      name: Value(name),
      intervalM: intervalM == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalM),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      lastDoneOdometerM: lastDoneOdometerM == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDoneOdometerM),
      lastDoneDateMs: lastDoneDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDoneDateMs),
      isActive: Value(isActive),
      iconKey: Value(iconKey),
      sortOrder: Value(sortOrder),
    );
  }

  factory ServiceItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceItemRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      name: serializer.fromJson<String>(json['name']),
      intervalM: serializer.fromJson<int?>(json['intervalM']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      lastDoneOdometerM: serializer.fromJson<int?>(json['lastDoneOdometerM']),
      lastDoneDateMs: serializer.fromJson<int?>(json['lastDoneDateMs']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'name': serializer.toJson<String>(name),
      'intervalM': serializer.toJson<int?>(intervalM),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'lastDoneOdometerM': serializer.toJson<int?>(lastDoneOdometerM),
      'lastDoneDateMs': serializer.toJson<int?>(lastDoneDateMs),
      'isActive': serializer.toJson<bool>(isActive),
      'iconKey': serializer.toJson<String>(iconKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ServiceItemRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    String? name,
    Value<int?> intervalM = const Value.absent(),
    Value<int?> intervalDays = const Value.absent(),
    Value<int?> lastDoneOdometerM = const Value.absent(),
    Value<int?> lastDoneDateMs = const Value.absent(),
    bool? isActive,
    String? iconKey,
    int? sortOrder,
  }) => ServiceItemRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    name: name ?? this.name,
    intervalM: intervalM.present ? intervalM.value : this.intervalM,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    lastDoneOdometerM: lastDoneOdometerM.present
        ? lastDoneOdometerM.value
        : this.lastDoneOdometerM,
    lastDoneDateMs: lastDoneDateMs.present
        ? lastDoneDateMs.value
        : this.lastDoneDateMs,
    isActive: isActive ?? this.isActive,
    iconKey: iconKey ?? this.iconKey,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ServiceItemRow copyWithCompanion(ServiceItemsCompanion data) {
    return ServiceItemRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      name: data.name.present ? data.name.value : this.name,
      intervalM: data.intervalM.present ? data.intervalM.value : this.intervalM,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      lastDoneOdometerM: data.lastDoneOdometerM.present
          ? data.lastDoneOdometerM.value
          : this.lastDoneOdometerM,
      lastDoneDateMs: data.lastDoneDateMs.present
          ? data.lastDoneDateMs.value
          : this.lastDoneDateMs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('intervalM: $intervalM, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastDoneOdometerM: $lastDoneOdometerM, ')
          ..write('lastDoneDateMs: $lastDoneDateMs, ')
          ..write('isActive: $isActive, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    name,
    intervalM,
    intervalDays,
    lastDoneOdometerM,
    lastDoneDateMs,
    isActive,
    iconKey,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceItemRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.name == this.name &&
          other.intervalM == this.intervalM &&
          other.intervalDays == this.intervalDays &&
          other.lastDoneOdometerM == this.lastDoneOdometerM &&
          other.lastDoneDateMs == this.lastDoneDateMs &&
          other.isActive == this.isActive &&
          other.iconKey == this.iconKey &&
          other.sortOrder == this.sortOrder);
}

class ServiceItemsCompanion extends UpdateCompanion<ServiceItemRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<String> name;
  final Value<int?> intervalM;
  final Value<int?> intervalDays;
  final Value<int?> lastDoneOdometerM;
  final Value<int?> lastDoneDateMs;
  final Value<bool> isActive;
  final Value<String> iconKey;
  final Value<int> sortOrder;
  const ServiceItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.name = const Value.absent(),
    this.intervalM = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastDoneOdometerM = const Value.absent(),
    this.lastDoneDateMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ServiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    required String name,
    this.intervalM = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.lastDoneOdometerM = const Value.absent(),
    this.lastDoneDateMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       name = Value(name);
  static Insertable<ServiceItemRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<String>? name,
    Expression<int>? intervalM,
    Expression<int>? intervalDays,
    Expression<int>? lastDoneOdometerM,
    Expression<int>? lastDoneDateMs,
    Expression<bool>? isActive,
    Expression<String>? iconKey,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (name != null) 'name': name,
      if (intervalM != null) 'interval_m': intervalM,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (lastDoneOdometerM != null) 'last_done_odometer_m': lastDoneOdometerM,
      if (lastDoneDateMs != null) 'last_done_date_ms': lastDoneDateMs,
      if (isActive != null) 'is_active': isActive,
      if (iconKey != null) 'icon_key': iconKey,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ServiceItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<String>? name,
    Value<int?>? intervalM,
    Value<int?>? intervalDays,
    Value<int?>? lastDoneOdometerM,
    Value<int?>? lastDoneDateMs,
    Value<bool>? isActive,
    Value<String>? iconKey,
    Value<int>? sortOrder,
  }) {
    return ServiceItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      name: name ?? this.name,
      intervalM: intervalM ?? this.intervalM,
      intervalDays: intervalDays ?? this.intervalDays,
      lastDoneOdometerM: lastDoneOdometerM ?? this.lastDoneOdometerM,
      lastDoneDateMs: lastDoneDateMs ?? this.lastDoneDateMs,
      isActive: isActive ?? this.isActive,
      iconKey: iconKey ?? this.iconKey,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (intervalM.present) {
      map['interval_m'] = Variable<int>(intervalM.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (lastDoneOdometerM.present) {
      map['last_done_odometer_m'] = Variable<int>(lastDoneOdometerM.value);
    }
    if (lastDoneDateMs.present) {
      map['last_done_date_ms'] = Variable<int>(lastDoneDateMs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('name: $name, ')
          ..write('intervalM: $intervalM, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('lastDoneOdometerM: $lastDoneOdometerM, ')
          ..write('lastDoneDateMs: $lastDoneDateMs, ')
          ..write('isActive: $isActive, ')
          ..write('iconKey: $iconKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ServiceLogsTable extends ServiceLogs
    with TableInfo<$ServiceLogsTable, ServiceLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serviceItemIdMeta = const VerificationMeta(
    'serviceItemId',
  );
  @override
  late final GeneratedColumn<int> serviceItemId = GeneratedColumn<int>(
    'service_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_items (id) ON DELETE SET NULL',
    ),
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
  static const VerificationMeta _dateMsMeta = const VerificationMeta('dateMs');
  @override
  late final GeneratedColumn<int> dateMs = GeneratedColumn<int>(
    'date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerMMeta = const VerificationMeta(
    'odometerM',
  );
  @override
  late final GeneratedColumn<int> odometerM = GeneratedColumn<int>(
    'odometer_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partsCostMinorMeta = const VerificationMeta(
    'partsCostMinor',
  );
  @override
  late final GeneratedColumn<int> partsCostMinor = GeneratedColumn<int>(
    'parts_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _laborCostMinorMeta = const VerificationMeta(
    'laborCostMinor',
  );
  @override
  late final GeneratedColumn<int> laborCostMinor = GeneratedColumn<int>(
    'labor_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCostMinorMeta = const VerificationMeta(
    'totalCostMinor',
  );
  @override
  late final GeneratedColumn<int> totalCostMinor = GeneratedColumn<int>(
    'total_cost_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _workshopMeta = const VerificationMeta(
    'workshop',
  );
  @override
  late final GeneratedColumn<String> workshop = GeneratedColumn<String>(
    'workshop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partBrandMeta = const VerificationMeta(
    'partBrand',
  );
  @override
  late final GeneratedColumn<String> partBrand = GeneratedColumn<String>(
    'part_brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueOdometerMMeta = const VerificationMeta(
    'nextDueOdometerM',
  );
  @override
  late final GeneratedColumn<int> nextDueOdometerM = GeneratedColumn<int>(
    'next_due_odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMsMeta = const VerificationMeta(
    'nextDueDateMs',
  );
  @override
  late final GeneratedColumn<int> nextDueDateMs = GeneratedColumn<int>(
    'next_due_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    serviceItemId,
    name,
    dateMs,
    odometerM,
    partsCostMinor,
    laborCostMinor,
    totalCostMinor,
    workshop,
    partBrand,
    notes,
    nextDueOdometerM,
    nextDueDateMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('service_item_id')) {
      context.handle(
        _serviceItemIdMeta,
        serviceItemId.isAcceptableOrUnknown(
          data['service_item_id']!,
          _serviceItemIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date_ms')) {
      context.handle(
        _dateMsMeta,
        dateMs.isAcceptableOrUnknown(data['date_ms']!, _dateMsMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMsMeta);
    }
    if (data.containsKey('odometer_m')) {
      context.handle(
        _odometerMMeta,
        odometerM.isAcceptableOrUnknown(data['odometer_m']!, _odometerMMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerMMeta);
    }
    if (data.containsKey('parts_cost_minor')) {
      context.handle(
        _partsCostMinorMeta,
        partsCostMinor.isAcceptableOrUnknown(
          data['parts_cost_minor']!,
          _partsCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('labor_cost_minor')) {
      context.handle(
        _laborCostMinorMeta,
        laborCostMinor.isAcceptableOrUnknown(
          data['labor_cost_minor']!,
          _laborCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('total_cost_minor')) {
      context.handle(
        _totalCostMinorMeta,
        totalCostMinor.isAcceptableOrUnknown(
          data['total_cost_minor']!,
          _totalCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('workshop')) {
      context.handle(
        _workshopMeta,
        workshop.isAcceptableOrUnknown(data['workshop']!, _workshopMeta),
      );
    }
    if (data.containsKey('part_brand')) {
      context.handle(
        _partBrandMeta,
        partBrand.isAcceptableOrUnknown(data['part_brand']!, _partBrandMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('next_due_odometer_m')) {
      context.handle(
        _nextDueOdometerMMeta,
        nextDueOdometerM.isAcceptableOrUnknown(
          data['next_due_odometer_m']!,
          _nextDueOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('next_due_date_ms')) {
      context.handle(
        _nextDueDateMsMeta,
        nextDueDateMs.isAcceptableOrUnknown(
          data['next_due_date_ms']!,
          _nextDueDateMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      serviceItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_item_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_ms'],
      )!,
      odometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_m'],
      )!,
      partsCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parts_cost_minor'],
      )!,
      laborCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}labor_cost_minor'],
      )!,
      totalCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_minor'],
      )!,
      workshop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workshop'],
      ),
      partBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_brand'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      nextDueOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_odometer_m'],
      ),
      nextDueDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_due_date_ms'],
      ),
    );
  }

  @override
  $ServiceLogsTable createAlias(String alias) {
    return $ServiceLogsTable(attachedDatabase, alias);
  }
}

class ServiceLogRow extends DataClass implements Insertable<ServiceLogRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final int? serviceItemId;

  /// Denormalised from the item at log time so history stays readable after
  /// the item is renamed or deleted.
  final String name;
  final int dateMs;
  final int odometerM;
  final int partsCostMinor;
  final int laborCostMinor;

  /// Authoritative total. Usually parts+labour, but kept separate so a
  /// bundled workshop bill can be entered as one number.
  final int totalCostMinor;
  final String? workshop;
  final String? partBrand;
  final String? notes;

  /// Snapshot of the next due point at the time of logging, so history shows
  /// what was expected then even if the interval changes later.
  final int? nextDueOdometerM;
  final int? nextDueDateMs;
  const ServiceLogRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    this.serviceItemId,
    required this.name,
    required this.dateMs,
    required this.odometerM,
    required this.partsCostMinor,
    required this.laborCostMinor,
    required this.totalCostMinor,
    this.workshop,
    this.partBrand,
    this.notes,
    this.nextDueOdometerM,
    this.nextDueDateMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    if (!nullToAbsent || serviceItemId != null) {
      map['service_item_id'] = Variable<int>(serviceItemId);
    }
    map['name'] = Variable<String>(name);
    map['date_ms'] = Variable<int>(dateMs);
    map['odometer_m'] = Variable<int>(odometerM);
    map['parts_cost_minor'] = Variable<int>(partsCostMinor);
    map['labor_cost_minor'] = Variable<int>(laborCostMinor);
    map['total_cost_minor'] = Variable<int>(totalCostMinor);
    if (!nullToAbsent || workshop != null) {
      map['workshop'] = Variable<String>(workshop);
    }
    if (!nullToAbsent || partBrand != null) {
      map['part_brand'] = Variable<String>(partBrand);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || nextDueOdometerM != null) {
      map['next_due_odometer_m'] = Variable<int>(nextDueOdometerM);
    }
    if (!nullToAbsent || nextDueDateMs != null) {
      map['next_due_date_ms'] = Variable<int>(nextDueDateMs);
    }
    return map;
  }

  ServiceLogsCompanion toCompanion(bool nullToAbsent) {
    return ServiceLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      serviceItemId: serviceItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceItemId),
      name: Value(name),
      dateMs: Value(dateMs),
      odometerM: Value(odometerM),
      partsCostMinor: Value(partsCostMinor),
      laborCostMinor: Value(laborCostMinor),
      totalCostMinor: Value(totalCostMinor),
      workshop: workshop == null && nullToAbsent
          ? const Value.absent()
          : Value(workshop),
      partBrand: partBrand == null && nullToAbsent
          ? const Value.absent()
          : Value(partBrand),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      nextDueOdometerM: nextDueOdometerM == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueOdometerM),
      nextDueDateMs: nextDueDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDateMs),
    );
  }

  factory ServiceLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceLogRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      serviceItemId: serializer.fromJson<int?>(json['serviceItemId']),
      name: serializer.fromJson<String>(json['name']),
      dateMs: serializer.fromJson<int>(json['dateMs']),
      odometerM: serializer.fromJson<int>(json['odometerM']),
      partsCostMinor: serializer.fromJson<int>(json['partsCostMinor']),
      laborCostMinor: serializer.fromJson<int>(json['laborCostMinor']),
      totalCostMinor: serializer.fromJson<int>(json['totalCostMinor']),
      workshop: serializer.fromJson<String?>(json['workshop']),
      partBrand: serializer.fromJson<String?>(json['partBrand']),
      notes: serializer.fromJson<String?>(json['notes']),
      nextDueOdometerM: serializer.fromJson<int?>(json['nextDueOdometerM']),
      nextDueDateMs: serializer.fromJson<int?>(json['nextDueDateMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'serviceItemId': serializer.toJson<int?>(serviceItemId),
      'name': serializer.toJson<String>(name),
      'dateMs': serializer.toJson<int>(dateMs),
      'odometerM': serializer.toJson<int>(odometerM),
      'partsCostMinor': serializer.toJson<int>(partsCostMinor),
      'laborCostMinor': serializer.toJson<int>(laborCostMinor),
      'totalCostMinor': serializer.toJson<int>(totalCostMinor),
      'workshop': serializer.toJson<String?>(workshop),
      'partBrand': serializer.toJson<String?>(partBrand),
      'notes': serializer.toJson<String?>(notes),
      'nextDueOdometerM': serializer.toJson<int?>(nextDueOdometerM),
      'nextDueDateMs': serializer.toJson<int?>(nextDueDateMs),
    };
  }

  ServiceLogRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    Value<int?> serviceItemId = const Value.absent(),
    String? name,
    int? dateMs,
    int? odometerM,
    int? partsCostMinor,
    int? laborCostMinor,
    int? totalCostMinor,
    Value<String?> workshop = const Value.absent(),
    Value<String?> partBrand = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> nextDueOdometerM = const Value.absent(),
    Value<int?> nextDueDateMs = const Value.absent(),
  }) => ServiceLogRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    serviceItemId: serviceItemId.present
        ? serviceItemId.value
        : this.serviceItemId,
    name: name ?? this.name,
    dateMs: dateMs ?? this.dateMs,
    odometerM: odometerM ?? this.odometerM,
    partsCostMinor: partsCostMinor ?? this.partsCostMinor,
    laborCostMinor: laborCostMinor ?? this.laborCostMinor,
    totalCostMinor: totalCostMinor ?? this.totalCostMinor,
    workshop: workshop.present ? workshop.value : this.workshop,
    partBrand: partBrand.present ? partBrand.value : this.partBrand,
    notes: notes.present ? notes.value : this.notes,
    nextDueOdometerM: nextDueOdometerM.present
        ? nextDueOdometerM.value
        : this.nextDueOdometerM,
    nextDueDateMs: nextDueDateMs.present
        ? nextDueDateMs.value
        : this.nextDueDateMs,
  );
  ServiceLogRow copyWithCompanion(ServiceLogsCompanion data) {
    return ServiceLogRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      serviceItemId: data.serviceItemId.present
          ? data.serviceItemId.value
          : this.serviceItemId,
      name: data.name.present ? data.name.value : this.name,
      dateMs: data.dateMs.present ? data.dateMs.value : this.dateMs,
      odometerM: data.odometerM.present ? data.odometerM.value : this.odometerM,
      partsCostMinor: data.partsCostMinor.present
          ? data.partsCostMinor.value
          : this.partsCostMinor,
      laborCostMinor: data.laborCostMinor.present
          ? data.laborCostMinor.value
          : this.laborCostMinor,
      totalCostMinor: data.totalCostMinor.present
          ? data.totalCostMinor.value
          : this.totalCostMinor,
      workshop: data.workshop.present ? data.workshop.value : this.workshop,
      partBrand: data.partBrand.present ? data.partBrand.value : this.partBrand,
      notes: data.notes.present ? data.notes.value : this.notes,
      nextDueOdometerM: data.nextDueOdometerM.present
          ? data.nextDueOdometerM.value
          : this.nextDueOdometerM,
      nextDueDateMs: data.nextDueDateMs.present
          ? data.nextDueDateMs.value
          : this.nextDueDateMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceLogRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('serviceItemId: $serviceItemId, ')
          ..write('name: $name, ')
          ..write('dateMs: $dateMs, ')
          ..write('odometerM: $odometerM, ')
          ..write('partsCostMinor: $partsCostMinor, ')
          ..write('laborCostMinor: $laborCostMinor, ')
          ..write('totalCostMinor: $totalCostMinor, ')
          ..write('workshop: $workshop, ')
          ..write('partBrand: $partBrand, ')
          ..write('notes: $notes, ')
          ..write('nextDueOdometerM: $nextDueOdometerM, ')
          ..write('nextDueDateMs: $nextDueDateMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    serviceItemId,
    name,
    dateMs,
    odometerM,
    partsCostMinor,
    laborCostMinor,
    totalCostMinor,
    workshop,
    partBrand,
    notes,
    nextDueOdometerM,
    nextDueDateMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceLogRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.serviceItemId == this.serviceItemId &&
          other.name == this.name &&
          other.dateMs == this.dateMs &&
          other.odometerM == this.odometerM &&
          other.partsCostMinor == this.partsCostMinor &&
          other.laborCostMinor == this.laborCostMinor &&
          other.totalCostMinor == this.totalCostMinor &&
          other.workshop == this.workshop &&
          other.partBrand == this.partBrand &&
          other.notes == this.notes &&
          other.nextDueOdometerM == this.nextDueOdometerM &&
          other.nextDueDateMs == this.nextDueDateMs);
}

class ServiceLogsCompanion extends UpdateCompanion<ServiceLogRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<int?> serviceItemId;
  final Value<String> name;
  final Value<int> dateMs;
  final Value<int> odometerM;
  final Value<int> partsCostMinor;
  final Value<int> laborCostMinor;
  final Value<int> totalCostMinor;
  final Value<String?> workshop;
  final Value<String?> partBrand;
  final Value<String?> notes;
  final Value<int?> nextDueOdometerM;
  final Value<int?> nextDueDateMs;
  const ServiceLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.serviceItemId = const Value.absent(),
    this.name = const Value.absent(),
    this.dateMs = const Value.absent(),
    this.odometerM = const Value.absent(),
    this.partsCostMinor = const Value.absent(),
    this.laborCostMinor = const Value.absent(),
    this.totalCostMinor = const Value.absent(),
    this.workshop = const Value.absent(),
    this.partBrand = const Value.absent(),
    this.notes = const Value.absent(),
    this.nextDueOdometerM = const Value.absent(),
    this.nextDueDateMs = const Value.absent(),
  });
  ServiceLogsCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    this.serviceItemId = const Value.absent(),
    required String name,
    required int dateMs,
    required int odometerM,
    this.partsCostMinor = const Value.absent(),
    this.laborCostMinor = const Value.absent(),
    this.totalCostMinor = const Value.absent(),
    this.workshop = const Value.absent(),
    this.partBrand = const Value.absent(),
    this.notes = const Value.absent(),
    this.nextDueOdometerM = const Value.absent(),
    this.nextDueDateMs = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       name = Value(name),
       dateMs = Value(dateMs),
       odometerM = Value(odometerM);
  static Insertable<ServiceLogRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<int>? serviceItemId,
    Expression<String>? name,
    Expression<int>? dateMs,
    Expression<int>? odometerM,
    Expression<int>? partsCostMinor,
    Expression<int>? laborCostMinor,
    Expression<int>? totalCostMinor,
    Expression<String>? workshop,
    Expression<String>? partBrand,
    Expression<String>? notes,
    Expression<int>? nextDueOdometerM,
    Expression<int>? nextDueDateMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (serviceItemId != null) 'service_item_id': serviceItemId,
      if (name != null) 'name': name,
      if (dateMs != null) 'date_ms': dateMs,
      if (odometerM != null) 'odometer_m': odometerM,
      if (partsCostMinor != null) 'parts_cost_minor': partsCostMinor,
      if (laborCostMinor != null) 'labor_cost_minor': laborCostMinor,
      if (totalCostMinor != null) 'total_cost_minor': totalCostMinor,
      if (workshop != null) 'workshop': workshop,
      if (partBrand != null) 'part_brand': partBrand,
      if (notes != null) 'notes': notes,
      if (nextDueOdometerM != null) 'next_due_odometer_m': nextDueOdometerM,
      if (nextDueDateMs != null) 'next_due_date_ms': nextDueDateMs,
    });
  }

  ServiceLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<int?>? serviceItemId,
    Value<String>? name,
    Value<int>? dateMs,
    Value<int>? odometerM,
    Value<int>? partsCostMinor,
    Value<int>? laborCostMinor,
    Value<int>? totalCostMinor,
    Value<String?>? workshop,
    Value<String?>? partBrand,
    Value<String?>? notes,
    Value<int?>? nextDueOdometerM,
    Value<int?>? nextDueDateMs,
  }) {
    return ServiceLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceItemId: serviceItemId ?? this.serviceItemId,
      name: name ?? this.name,
      dateMs: dateMs ?? this.dateMs,
      odometerM: odometerM ?? this.odometerM,
      partsCostMinor: partsCostMinor ?? this.partsCostMinor,
      laborCostMinor: laborCostMinor ?? this.laborCostMinor,
      totalCostMinor: totalCostMinor ?? this.totalCostMinor,
      workshop: workshop ?? this.workshop,
      partBrand: partBrand ?? this.partBrand,
      notes: notes ?? this.notes,
      nextDueOdometerM: nextDueOdometerM ?? this.nextDueOdometerM,
      nextDueDateMs: nextDueDateMs ?? this.nextDueDateMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (serviceItemId.present) {
      map['service_item_id'] = Variable<int>(serviceItemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dateMs.present) {
      map['date_ms'] = Variable<int>(dateMs.value);
    }
    if (odometerM.present) {
      map['odometer_m'] = Variable<int>(odometerM.value);
    }
    if (partsCostMinor.present) {
      map['parts_cost_minor'] = Variable<int>(partsCostMinor.value);
    }
    if (laborCostMinor.present) {
      map['labor_cost_minor'] = Variable<int>(laborCostMinor.value);
    }
    if (totalCostMinor.present) {
      map['total_cost_minor'] = Variable<int>(totalCostMinor.value);
    }
    if (workshop.present) {
      map['workshop'] = Variable<String>(workshop.value);
    }
    if (partBrand.present) {
      map['part_brand'] = Variable<String>(partBrand.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (nextDueOdometerM.present) {
      map['next_due_odometer_m'] = Variable<int>(nextDueOdometerM.value);
    }
    if (nextDueDateMs.present) {
      map['next_due_date_ms'] = Variable<int>(nextDueDateMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('serviceItemId: $serviceItemId, ')
          ..write('name: $name, ')
          ..write('dateMs: $dateMs, ')
          ..write('odometerM: $odometerM, ')
          ..write('partsCostMinor: $partsCostMinor, ')
          ..write('laborCostMinor: $laborCostMinor, ')
          ..write('totalCostMinor: $totalCostMinor, ')
          ..write('workshop: $workshop, ')
          ..write('partBrand: $partBrand, ')
          ..write('notes: $notes, ')
          ..write('nextDueOdometerM: $nextDueOdometerM, ')
          ..write('nextDueDateMs: $nextDueDateMs')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ExpenseCategory>($ExpensesTable.$convertercategory);
  static const VerificationMeta _dateMsMeta = const VerificationMeta('dateMs');
  @override
  late final GeneratedColumn<int> dateMs = GeneratedColumn<int>(
    'date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validFromMsMeta = const VerificationMeta(
    'validFromMs',
  );
  @override
  late final GeneratedColumn<int> validFromMs = GeneratedColumn<int>(
    'valid_from_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validUntilMsMeta = const VerificationMeta(
    'validUntilMs',
  );
  @override
  late final GeneratedColumn<int> validUntilMs = GeneratedColumn<int>(
    'valid_until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    category,
    dateMs,
    amountMinor,
    notes,
    validFromMs,
    validUntilMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date_ms')) {
      context.handle(
        _dateMsMeta,
        dateMs.isAcceptableOrUnknown(data['date_ms']!, _dateMsMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMsMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('valid_from_ms')) {
      context.handle(
        _validFromMsMeta,
        validFromMs.isAcceptableOrUnknown(
          data['valid_from_ms']!,
          _validFromMsMeta,
        ),
      );
    }
    if (data.containsKey('valid_until_ms')) {
      context.handle(
        _validUntilMsMeta,
        validUntilMs.isAcceptableOrUnknown(
          data['valid_until_ms']!,
          _validUntilMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      category: $ExpensesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      dateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_ms'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      validFromMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_from_ms'],
      ),
      validUntilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_until_ms'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseCategory, String, String>
  $convertercategory = const EnumNameConverter<ExpenseCategory>(
    ExpenseCategory.values,
  );
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final ExpenseCategory category;
  final int dateMs;
  final int amountMinor;
  final String? notes;

  /// Coverage period for documents. [validUntilMs] drives expiry countdowns
  /// and reminders.
  final int? validFromMs;
  final int? validUntilMs;
  const ExpenseRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    required this.category,
    required this.dateMs,
    required this.amountMinor,
    this.notes,
    this.validFromMs,
    this.validUntilMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category),
      );
    }
    map['date_ms'] = Variable<int>(dateMs);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || validFromMs != null) {
      map['valid_from_ms'] = Variable<int>(validFromMs);
    }
    if (!nullToAbsent || validUntilMs != null) {
      map['valid_until_ms'] = Variable<int>(validUntilMs);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      category: Value(category),
      dateMs: Value(dateMs),
      amountMinor: Value(amountMinor),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      validFromMs: validFromMs == null && nullToAbsent
          ? const Value.absent()
          : Value(validFromMs),
      validUntilMs: validUntilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntilMs),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      category: $ExpensesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      dateMs: serializer.fromJson<int>(json['dateMs']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      notes: serializer.fromJson<String?>(json['notes']),
      validFromMs: serializer.fromJson<int?>(json['validFromMs']),
      validUntilMs: serializer.fromJson<int?>(json['validUntilMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'category': serializer.toJson<String>(
        $ExpensesTable.$convertercategory.toJson(category),
      ),
      'dateMs': serializer.toJson<int>(dateMs),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'notes': serializer.toJson<String?>(notes),
      'validFromMs': serializer.toJson<int?>(validFromMs),
      'validUntilMs': serializer.toJson<int?>(validUntilMs),
    };
  }

  ExpenseRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    ExpenseCategory? category,
    int? dateMs,
    int? amountMinor,
    Value<String?> notes = const Value.absent(),
    Value<int?> validFromMs = const Value.absent(),
    Value<int?> validUntilMs = const Value.absent(),
  }) => ExpenseRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    category: category ?? this.category,
    dateMs: dateMs ?? this.dateMs,
    amountMinor: amountMinor ?? this.amountMinor,
    notes: notes.present ? notes.value : this.notes,
    validFromMs: validFromMs.present ? validFromMs.value : this.validFromMs,
    validUntilMs: validUntilMs.present ? validUntilMs.value : this.validUntilMs,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      category: data.category.present ? data.category.value : this.category,
      dateMs: data.dateMs.present ? data.dateMs.value : this.dateMs,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      notes: data.notes.present ? data.notes.value : this.notes,
      validFromMs: data.validFromMs.present
          ? data.validFromMs.value
          : this.validFromMs,
      validUntilMs: data.validUntilMs.present
          ? data.validUntilMs.value
          : this.validUntilMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('category: $category, ')
          ..write('dateMs: $dateMs, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('notes: $notes, ')
          ..write('validFromMs: $validFromMs, ')
          ..write('validUntilMs: $validUntilMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    category,
    dateMs,
    amountMinor,
    notes,
    validFromMs,
    validUntilMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.category == this.category &&
          other.dateMs == this.dateMs &&
          other.amountMinor == this.amountMinor &&
          other.notes == this.notes &&
          other.validFromMs == this.validFromMs &&
          other.validUntilMs == this.validUntilMs);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<ExpenseCategory> category;
  final Value<int> dateMs;
  final Value<int> amountMinor;
  final Value<String?> notes;
  final Value<int?> validFromMs;
  final Value<int?> validUntilMs;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.category = const Value.absent(),
    this.dateMs = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.notes = const Value.absent(),
    this.validFromMs = const Value.absent(),
    this.validUntilMs = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    required ExpenseCategory category,
    required int dateMs,
    required int amountMinor,
    this.notes = const Value.absent(),
    this.validFromMs = const Value.absent(),
    this.validUntilMs = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       category = Value(category),
       dateMs = Value(dateMs),
       amountMinor = Value(amountMinor);
  static Insertable<ExpenseRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<String>? category,
    Expression<int>? dateMs,
    Expression<int>? amountMinor,
    Expression<String>? notes,
    Expression<int>? validFromMs,
    Expression<int>? validUntilMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (category != null) 'category': category,
      if (dateMs != null) 'date_ms': dateMs,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (notes != null) 'notes': notes,
      if (validFromMs != null) 'valid_from_ms': validFromMs,
      if (validUntilMs != null) 'valid_until_ms': validUntilMs,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<ExpenseCategory>? category,
    Value<int>? dateMs,
    Value<int>? amountMinor,
    Value<String?>? notes,
    Value<int?>? validFromMs,
    Value<int?>? validUntilMs,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      category: category ?? this.category,
      dateMs: dateMs ?? this.dateMs,
      amountMinor: amountMinor ?? this.amountMinor,
      notes: notes ?? this.notes,
      validFromMs: validFromMs ?? this.validFromMs,
      validUntilMs: validUntilMs ?? this.validUntilMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category.value),
      );
    }
    if (dateMs.present) {
      map['date_ms'] = Variable<int>(dateMs.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (validFromMs.present) {
      map['valid_from_ms'] = Variable<int>(validFromMs.value);
    }
    if (validUntilMs.present) {
      map['valid_until_ms'] = Variable<int>(validUntilMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('category: $category, ')
          ..write('dateMs: $dateMs, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('notes: $notes, ')
          ..write('validFromMs: $validFromMs, ')
          ..write('validUntilMs: $validUntilMs')
          ..write(')'))
        .toString();
  }
}

class $RidesTable extends Rides with TableInfo<$RidesTable, RideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startTimeMsMeta = const VerificationMeta(
    'startTimeMs',
  );
  @override
  late final GeneratedColumn<int> startTimeMs = GeneratedColumn<int>(
    'start_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMsMeta = const VerificationMeta(
    'endTimeMs',
  );
  @override
  late final GeneratedColumn<int> endTimeMs = GeneratedColumn<int>(
    'end_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingSecondsMeta = const VerificationMeta(
    'movingSeconds',
  );
  @override
  late final GeneratedColumn<int> movingSeconds = GeneratedColumn<int>(
    'moving_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSecondsMeta = const VerificationMeta(
    'totalSeconds',
  );
  @override
  late final GeneratedColumn<int> totalSeconds = GeneratedColumn<int>(
    'total_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgSpeedMeta = const VerificationMeta(
    'avgSpeed',
  );
  @override
  late final GeneratedColumn<double> avgSpeed = GeneratedColumn<double>(
    'avg_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSpeedMeta = const VerificationMeta(
    'maxSpeed',
  );
  @override
  late final GeneratedColumn<double> maxSpeed = GeneratedColumn<double>(
    'max_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startOdometerMMeta = const VerificationMeta(
    'startOdometerM',
  );
  @override
  late final GeneratedColumn<int> startOdometerM = GeneratedColumn<int>(
    'start_odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endOdometerMMeta = const VerificationMeta(
    'endOdometerM',
  );
  @override
  late final GeneratedColumn<int> endOdometerM = GeneratedColumn<int>(
    'end_odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    startTimeMs,
    endTimeMs,
    distanceMeters,
    movingSeconds,
    totalSeconds,
    avgSpeed,
    maxSpeed,
    startOdometerM,
    endOdometerM,
    title,
    notes,
    isComplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rides';
  @override
  VerificationContext validateIntegrity(
    Insertable<RideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('start_time_ms')) {
      context.handle(
        _startTimeMsMeta,
        startTimeMs.isAcceptableOrUnknown(
          data['start_time_ms']!,
          _startTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeMsMeta);
    }
    if (data.containsKey('end_time_ms')) {
      context.handle(
        _endTimeMsMeta,
        endTimeMs.isAcceptableOrUnknown(data['end_time_ms']!, _endTimeMsMeta),
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
    if (data.containsKey('moving_seconds')) {
      context.handle(
        _movingSecondsMeta,
        movingSeconds.isAcceptableOrUnknown(
          data['moving_seconds']!,
          _movingSecondsMeta,
        ),
      );
    }
    if (data.containsKey('total_seconds')) {
      context.handle(
        _totalSecondsMeta,
        totalSeconds.isAcceptableOrUnknown(
          data['total_seconds']!,
          _totalSecondsMeta,
        ),
      );
    }
    if (data.containsKey('avg_speed')) {
      context.handle(
        _avgSpeedMeta,
        avgSpeed.isAcceptableOrUnknown(data['avg_speed']!, _avgSpeedMeta),
      );
    }
    if (data.containsKey('max_speed')) {
      context.handle(
        _maxSpeedMeta,
        maxSpeed.isAcceptableOrUnknown(data['max_speed']!, _maxSpeedMeta),
      );
    }
    if (data.containsKey('start_odometer_m')) {
      context.handle(
        _startOdometerMMeta,
        startOdometerM.isAcceptableOrUnknown(
          data['start_odometer_m']!,
          _startOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('end_odometer_m')) {
      context.handle(
        _endOdometerMMeta,
        endOdometerM.isAcceptableOrUnknown(
          data['end_odometer_m']!,
          _endOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RideRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      startTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_ms'],
      )!,
      endTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time_ms'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_meters'],
      )!,
      movingSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_seconds'],
      )!,
      totalSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_seconds'],
      )!,
      avgSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_speed'],
      )!,
      maxSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed'],
      )!,
      startOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_odometer_m'],
      ),
      endOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_odometer_m'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
    );
  }

  @override
  $RidesTable createAlias(String alias) {
    return $RidesTable(attachedDatabase, alias);
  }
}

class RideRow extends DataClass implements Insertable<RideRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final int startTimeMs;

  /// Null while a ride is in progress. On launch, a ride with no end time is
  /// an interrupted recording and the user is offered resume/save/discard.
  final int? endTimeMs;
  final int distanceMeters;

  /// Kept apart from [totalSeconds] so average speed excludes time spent
  /// stopped at signals.
  final int movingSeconds;
  final int totalSeconds;

  /// Metres per second.
  final double avgSpeed;
  final double maxSpeed;
  final int? startOdometerM;
  final int? endOdometerM;
  final String? title;
  final String? notes;
  final bool isComplete;
  const RideRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    required this.startTimeMs,
    this.endTimeMs,
    required this.distanceMeters,
    required this.movingSeconds,
    required this.totalSeconds,
    required this.avgSpeed,
    required this.maxSpeed,
    this.startOdometerM,
    this.endOdometerM,
    this.title,
    this.notes,
    required this.isComplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['start_time_ms'] = Variable<int>(startTimeMs);
    if (!nullToAbsent || endTimeMs != null) {
      map['end_time_ms'] = Variable<int>(endTimeMs);
    }
    map['distance_meters'] = Variable<int>(distanceMeters);
    map['moving_seconds'] = Variable<int>(movingSeconds);
    map['total_seconds'] = Variable<int>(totalSeconds);
    map['avg_speed'] = Variable<double>(avgSpeed);
    map['max_speed'] = Variable<double>(maxSpeed);
    if (!nullToAbsent || startOdometerM != null) {
      map['start_odometer_m'] = Variable<int>(startOdometerM);
    }
    if (!nullToAbsent || endOdometerM != null) {
      map['end_odometer_m'] = Variable<int>(endOdometerM);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  RidesCompanion toCompanion(bool nullToAbsent) {
    return RidesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      startTimeMs: Value(startTimeMs),
      endTimeMs: endTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endTimeMs),
      distanceMeters: Value(distanceMeters),
      movingSeconds: Value(movingSeconds),
      totalSeconds: Value(totalSeconds),
      avgSpeed: Value(avgSpeed),
      maxSpeed: Value(maxSpeed),
      startOdometerM: startOdometerM == null && nullToAbsent
          ? const Value.absent()
          : Value(startOdometerM),
      endOdometerM: endOdometerM == null && nullToAbsent
          ? const Value.absent()
          : Value(endOdometerM),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isComplete: Value(isComplete),
    );
  }

  factory RideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RideRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      startTimeMs: serializer.fromJson<int>(json['startTimeMs']),
      endTimeMs: serializer.fromJson<int?>(json['endTimeMs']),
      distanceMeters: serializer.fromJson<int>(json['distanceMeters']),
      movingSeconds: serializer.fromJson<int>(json['movingSeconds']),
      totalSeconds: serializer.fromJson<int>(json['totalSeconds']),
      avgSpeed: serializer.fromJson<double>(json['avgSpeed']),
      maxSpeed: serializer.fromJson<double>(json['maxSpeed']),
      startOdometerM: serializer.fromJson<int?>(json['startOdometerM']),
      endOdometerM: serializer.fromJson<int?>(json['endOdometerM']),
      title: serializer.fromJson<String?>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'startTimeMs': serializer.toJson<int>(startTimeMs),
      'endTimeMs': serializer.toJson<int?>(endTimeMs),
      'distanceMeters': serializer.toJson<int>(distanceMeters),
      'movingSeconds': serializer.toJson<int>(movingSeconds),
      'totalSeconds': serializer.toJson<int>(totalSeconds),
      'avgSpeed': serializer.toJson<double>(avgSpeed),
      'maxSpeed': serializer.toJson<double>(maxSpeed),
      'startOdometerM': serializer.toJson<int?>(startOdometerM),
      'endOdometerM': serializer.toJson<int?>(endOdometerM),
      'title': serializer.toJson<String?>(title),
      'notes': serializer.toJson<String?>(notes),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  RideRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    int? startTimeMs,
    Value<int?> endTimeMs = const Value.absent(),
    int? distanceMeters,
    int? movingSeconds,
    int? totalSeconds,
    double? avgSpeed,
    double? maxSpeed,
    Value<int?> startOdometerM = const Value.absent(),
    Value<int?> endOdometerM = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isComplete,
  }) => RideRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    startTimeMs: startTimeMs ?? this.startTimeMs,
    endTimeMs: endTimeMs.present ? endTimeMs.value : this.endTimeMs,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    movingSeconds: movingSeconds ?? this.movingSeconds,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    avgSpeed: avgSpeed ?? this.avgSpeed,
    maxSpeed: maxSpeed ?? this.maxSpeed,
    startOdometerM: startOdometerM.present
        ? startOdometerM.value
        : this.startOdometerM,
    endOdometerM: endOdometerM.present ? endOdometerM.value : this.endOdometerM,
    title: title.present ? title.value : this.title,
    notes: notes.present ? notes.value : this.notes,
    isComplete: isComplete ?? this.isComplete,
  );
  RideRow copyWithCompanion(RidesCompanion data) {
    return RideRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      startTimeMs: data.startTimeMs.present
          ? data.startTimeMs.value
          : this.startTimeMs,
      endTimeMs: data.endTimeMs.present ? data.endTimeMs.value : this.endTimeMs,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      movingSeconds: data.movingSeconds.present
          ? data.movingSeconds.value
          : this.movingSeconds,
      totalSeconds: data.totalSeconds.present
          ? data.totalSeconds.value
          : this.totalSeconds,
      avgSpeed: data.avgSpeed.present ? data.avgSpeed.value : this.avgSpeed,
      maxSpeed: data.maxSpeed.present ? data.maxSpeed.value : this.maxSpeed,
      startOdometerM: data.startOdometerM.present
          ? data.startOdometerM.value
          : this.startOdometerM,
      endOdometerM: data.endOdometerM.present
          ? data.endOdometerM.value
          : this.endOdometerM,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RideRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('movingSeconds: $movingSeconds, ')
          ..write('totalSeconds: $totalSeconds, ')
          ..write('avgSpeed: $avgSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('startOdometerM: $startOdometerM, ')
          ..write('endOdometerM: $endOdometerM, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    startTimeMs,
    endTimeMs,
    distanceMeters,
    movingSeconds,
    totalSeconds,
    avgSpeed,
    maxSpeed,
    startOdometerM,
    endOdometerM,
    title,
    notes,
    isComplete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RideRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.startTimeMs == this.startTimeMs &&
          other.endTimeMs == this.endTimeMs &&
          other.distanceMeters == this.distanceMeters &&
          other.movingSeconds == this.movingSeconds &&
          other.totalSeconds == this.totalSeconds &&
          other.avgSpeed == this.avgSpeed &&
          other.maxSpeed == this.maxSpeed &&
          other.startOdometerM == this.startOdometerM &&
          other.endOdometerM == this.endOdometerM &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.isComplete == this.isComplete);
}

class RidesCompanion extends UpdateCompanion<RideRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<int> startTimeMs;
  final Value<int?> endTimeMs;
  final Value<int> distanceMeters;
  final Value<int> movingSeconds;
  final Value<int> totalSeconds;
  final Value<double> avgSpeed;
  final Value<double> maxSpeed;
  final Value<int?> startOdometerM;
  final Value<int?> endOdometerM;
  final Value<String?> title;
  final Value<String?> notes;
  final Value<bool> isComplete;
  const RidesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.startTimeMs = const Value.absent(),
    this.endTimeMs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.movingSeconds = const Value.absent(),
    this.totalSeconds = const Value.absent(),
    this.avgSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.startOdometerM = const Value.absent(),
    this.endOdometerM = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.isComplete = const Value.absent(),
  });
  RidesCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    required int startTimeMs,
    this.endTimeMs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.movingSeconds = const Value.absent(),
    this.totalSeconds = const Value.absent(),
    this.avgSpeed = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.startOdometerM = const Value.absent(),
    this.endOdometerM = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.isComplete = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       startTimeMs = Value(startTimeMs);
  static Insertable<RideRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<int>? startTimeMs,
    Expression<int>? endTimeMs,
    Expression<int>? distanceMeters,
    Expression<int>? movingSeconds,
    Expression<int>? totalSeconds,
    Expression<double>? avgSpeed,
    Expression<double>? maxSpeed,
    Expression<int>? startOdometerM,
    Expression<int>? endOdometerM,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<bool>? isComplete,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (startTimeMs != null) 'start_time_ms': startTimeMs,
      if (endTimeMs != null) 'end_time_ms': endTimeMs,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (movingSeconds != null) 'moving_seconds': movingSeconds,
      if (totalSeconds != null) 'total_seconds': totalSeconds,
      if (avgSpeed != null) 'avg_speed': avgSpeed,
      if (maxSpeed != null) 'max_speed': maxSpeed,
      if (startOdometerM != null) 'start_odometer_m': startOdometerM,
      if (endOdometerM != null) 'end_odometer_m': endOdometerM,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (isComplete != null) 'is_complete': isComplete,
    });
  }

  RidesCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<int>? startTimeMs,
    Value<int?>? endTimeMs,
    Value<int>? distanceMeters,
    Value<int>? movingSeconds,
    Value<int>? totalSeconds,
    Value<double>? avgSpeed,
    Value<double>? maxSpeed,
    Value<int?>? startOdometerM,
    Value<int?>? endOdometerM,
    Value<String?>? title,
    Value<String?>? notes,
    Value<bool>? isComplete,
  }) {
    return RidesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      endTimeMs: endTimeMs ?? this.endTimeMs,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      movingSeconds: movingSeconds ?? this.movingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      startOdometerM: startOdometerM ?? this.startOdometerM,
      endOdometerM: endOdometerM ?? this.endOdometerM,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (startTimeMs.present) {
      map['start_time_ms'] = Variable<int>(startTimeMs.value);
    }
    if (endTimeMs.present) {
      map['end_time_ms'] = Variable<int>(endTimeMs.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (movingSeconds.present) {
      map['moving_seconds'] = Variable<int>(movingSeconds.value);
    }
    if (totalSeconds.present) {
      map['total_seconds'] = Variable<int>(totalSeconds.value);
    }
    if (avgSpeed.present) {
      map['avg_speed'] = Variable<double>(avgSpeed.value);
    }
    if (maxSpeed.present) {
      map['max_speed'] = Variable<double>(maxSpeed.value);
    }
    if (startOdometerM.present) {
      map['start_odometer_m'] = Variable<int>(startOdometerM.value);
    }
    if (endOdometerM.present) {
      map['end_odometer_m'] = Variable<int>(endOdometerM.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RidesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('startTimeMs: $startTimeMs, ')
          ..write('endTimeMs: $endTimeMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('movingSeconds: $movingSeconds, ')
          ..write('totalSeconds: $totalSeconds, ')
          ..write('avgSpeed: $avgSpeed, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('startOdometerM: $startOdometerM, ')
          ..write('endOdometerM: $endOdometerM, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }
}

class $RidePointsTable extends RidePoints
    with TableInfo<$RidePointsTable, RidePointRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RidePointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
  late final GeneratedColumn<int> rideId = GeneratedColumn<int>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGapStartMeta = const VerificationMeta(
    'isGapStart',
  );
  @override
  late final GeneratedColumn<bool> isGapStart = GeneratedColumn<bool>(
    'is_gap_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_gap_start" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    lat,
    lng,
    timestampMs,
    speed,
    accuracy,
    altitude,
    isGapStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ride_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RidePointRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('is_gap_start')) {
      context.handle(
        _isGapStartMeta,
        isGapStart.isAcceptableOrUnknown(
          data['is_gap_start']!,
          _isGapStartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RidePointRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RidePointRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ride_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      isGapStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_gap_start'],
      )!,
    );
  }

  @override
  $RidePointsTable createAlias(String alias) {
    return $RidePointsTable(attachedDatabase, alias);
  }
}

class RidePointRow extends DataClass implements Insertable<RidePointRow> {
  final int id;
  final int rideId;
  final double lat;
  final double lng;
  final int timestampMs;

  /// Metres per second, as reported by the platform.
  final double? speed;

  /// Horizontal accuracy in metres. Samples worse than 30 m are discarded
  /// before they ever reach this table.
  final double? accuracy;
  final double? altitude;

  /// Marks the first point after a break in recording. The polyline breaks
  /// here instead of drawing a false straight line across the gap.
  final bool isGapStart;
  const RidePointRow({
    required this.id,
    required this.rideId,
    required this.lat,
    required this.lng,
    required this.timestampMs,
    this.speed,
    this.accuracy,
    this.altitude,
    required this.isGapStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<int>(rideId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['is_gap_start'] = Variable<bool>(isGapStart);
    return map;
  }

  RidePointsCompanion toCompanion(bool nullToAbsent) {
    return RidePointsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      lat: Value(lat),
      lng: Value(lng),
      timestampMs: Value(timestampMs),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      isGapStart: Value(isGapStart),
    );
  }

  factory RidePointRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RidePointRow(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<int>(json['rideId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      speed: serializer.fromJson<double?>(json['speed']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      isGapStart: serializer.fromJson<bool>(json['isGapStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<int>(rideId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'speed': serializer.toJson<double?>(speed),
      'accuracy': serializer.toJson<double?>(accuracy),
      'altitude': serializer.toJson<double?>(altitude),
      'isGapStart': serializer.toJson<bool>(isGapStart),
    };
  }

  RidePointRow copyWith({
    int? id,
    int? rideId,
    double? lat,
    double? lng,
    int? timestampMs,
    Value<double?> speed = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    Value<double?> altitude = const Value.absent(),
    bool? isGapStart,
  }) => RidePointRow(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    timestampMs: timestampMs ?? this.timestampMs,
    speed: speed.present ? speed.value : this.speed,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    altitude: altitude.present ? altitude.value : this.altitude,
    isGapStart: isGapStart ?? this.isGapStart,
  );
  RidePointRow copyWithCompanion(RidePointsCompanion data) {
    return RidePointRow(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      speed: data.speed.present ? data.speed.value : this.speed,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      isGapStart: data.isGapStart.present
          ? data.isGapStart.value
          : this.isGapStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RidePointRow(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('isGapStart: $isGapStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rideId,
    lat,
    lng,
    timestampMs,
    speed,
    accuracy,
    altitude,
    isGapStart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RidePointRow &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.timestampMs == this.timestampMs &&
          other.speed == this.speed &&
          other.accuracy == this.accuracy &&
          other.altitude == this.altitude &&
          other.isGapStart == this.isGapStart);
}

class RidePointsCompanion extends UpdateCompanion<RidePointRow> {
  final Value<int> id;
  final Value<int> rideId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> timestampMs;
  final Value<double?> speed;
  final Value<double?> accuracy;
  final Value<double?> altitude;
  final Value<bool> isGapStart;
  const RidePointsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.isGapStart = const Value.absent(),
  });
  RidePointsCompanion.insert({
    this.id = const Value.absent(),
    required int rideId,
    required double lat,
    required double lng,
    required int timestampMs,
    this.speed = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.isGapStart = const Value.absent(),
  }) : rideId = Value(rideId),
       lat = Value(lat),
       lng = Value(lng),
       timestampMs = Value(timestampMs);
  static Insertable<RidePointRow> custom({
    Expression<int>? id,
    Expression<int>? rideId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? timestampMs,
    Expression<double>? speed,
    Expression<double>? accuracy,
    Expression<double>? altitude,
    Expression<bool>? isGapStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (isGapStart != null) 'is_gap_start': isGapStart,
    });
  }

  RidePointsCompanion copyWith({
    Value<int>? id,
    Value<int>? rideId,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? timestampMs,
    Value<double?>? speed,
    Value<double?>? accuracy,
    Value<double?>? altitude,
    Value<bool>? isGapStart,
  }) {
    return RidePointsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      timestampMs: timestampMs ?? this.timestampMs,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      isGapStart: isGapStart ?? this.isGapStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<int>(rideId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (isGapStart.present) {
      map['is_gap_start'] = Variable<bool>(isGapStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RidePointsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('speed: $speed, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('isGapStart: $isGapStart')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderType>($RemindersTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMsMeta = const VerificationMeta(
    'dueDateMs',
  );
  @override
  late final GeneratedColumn<int> dueDateMs = GeneratedColumn<int>(
    'due_date_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueOdometerMMeta = const VerificationMeta(
    'dueOdometerM',
  );
  @override
  late final GeneratedColumn<int> dueOdometerM = GeneratedColumn<int>(
    'due_odometer_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDismissedMeta = const VerificationMeta(
    'isDismissed',
  );
  @override
  late final GeneratedColumn<bool> isDismissed = GeneratedColumn<bool>(
    'is_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notifiedAtMsMeta = const VerificationMeta(
    'notifiedAtMs',
  );
  @override
  late final GeneratedColumn<int> notifiedAtMs = GeneratedColumn<int>(
    'notified_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    type,
    title,
    dueDateMs,
    dueOdometerM,
    isDismissed,
    notifiedAtMs,
    sourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_date_ms')) {
      context.handle(
        _dueDateMsMeta,
        dueDateMs.isAcceptableOrUnknown(data['due_date_ms']!, _dueDateMsMeta),
      );
    }
    if (data.containsKey('due_odometer_m')) {
      context.handle(
        _dueOdometerMMeta,
        dueOdometerM.isAcceptableOrUnknown(
          data['due_odometer_m']!,
          _dueOdometerMMeta,
        ),
      );
    }
    if (data.containsKey('is_dismissed')) {
      context.handle(
        _isDismissedMeta,
        isDismissed.isAcceptableOrUnknown(
          data['is_dismissed']!,
          _isDismissedMeta,
        ),
      );
    }
    if (data.containsKey('notified_at_ms')) {
      context.handle(
        _notifiedAtMsMeta,
        notifiedAtMs.isAcceptableOrUnknown(
          data['notified_at_ms']!,
          _notifiedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      type: $RemindersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date_ms'],
      ),
      dueOdometerM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_odometer_m'],
      ),
      isDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dismissed'],
      )!,
      notifiedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notified_at_ms'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderType, String, String> $convertertype =
      const EnumNameConverter<ReminderType>(ReminderType.values);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;

  /// UTC epoch milliseconds. Always. Displayed in local time, never stored
  /// in it — otherwise a user crossing a timezone rewrites their history.
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int vehicleId;
  final ReminderType type;
  final String title;
  final int? dueDateMs;
  final int? dueOdometerM;
  final bool isDismissed;

  /// When the local notification was last posted, so it is not re-posted on
  /// every recompute.
  final int? notifiedAtMs;

  /// The service item or expense this reminder was generated from, so it can
  /// be regenerated idempotently rather than duplicated.
  final int? sourceId;
  const ReminderRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.vehicleId,
    required this.type,
    required this.title,
    this.dueDateMs,
    this.dueOdometerM,
    required this.isDismissed,
    this.notifiedAtMs,
    this.sourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['vehicle_id'] = Variable<int>(vehicleId);
    {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueDateMs != null) {
      map['due_date_ms'] = Variable<int>(dueDateMs);
    }
    if (!nullToAbsent || dueOdometerM != null) {
      map['due_odometer_m'] = Variable<int>(dueOdometerM);
    }
    map['is_dismissed'] = Variable<bool>(isDismissed);
    if (!nullToAbsent || notifiedAtMs != null) {
      map['notified_at_ms'] = Variable<int>(notifiedAtMs);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      vehicleId: Value(vehicleId),
      type: Value(type),
      title: Value(title),
      dueDateMs: dueDateMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateMs),
      dueOdometerM: dueOdometerM == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOdometerM),
      isDismissed: Value(isDismissed),
      notifiedAtMs: notifiedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(notifiedAtMs),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      type: $RemindersTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      dueDateMs: serializer.fromJson<int?>(json['dueDateMs']),
      dueOdometerM: serializer.fromJson<int?>(json['dueOdometerM']),
      isDismissed: serializer.fromJson<bool>(json['isDismissed']),
      notifiedAtMs: serializer.fromJson<int?>(json['notifiedAtMs']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'type': serializer.toJson<String>(
        $RemindersTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'dueDateMs': serializer.toJson<int?>(dueDateMs),
      'dueOdometerM': serializer.toJson<int?>(dueOdometerM),
      'isDismissed': serializer.toJson<bool>(isDismissed),
      'notifiedAtMs': serializer.toJson<int?>(notifiedAtMs),
      'sourceId': serializer.toJson<int?>(sourceId),
    };
  }

  ReminderRow copyWith({
    int? id,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? vehicleId,
    ReminderType? type,
    String? title,
    Value<int?> dueDateMs = const Value.absent(),
    Value<int?> dueOdometerM = const Value.absent(),
    bool? isDismissed,
    Value<int?> notifiedAtMs = const Value.absent(),
    Value<int?> sourceId = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    vehicleId: vehicleId ?? this.vehicleId,
    type: type ?? this.type,
    title: title ?? this.title,
    dueDateMs: dueDateMs.present ? dueDateMs.value : this.dueDateMs,
    dueOdometerM: dueOdometerM.present ? dueOdometerM.value : this.dueOdometerM,
    isDismissed: isDismissed ?? this.isDismissed,
    notifiedAtMs: notifiedAtMs.present ? notifiedAtMs.value : this.notifiedAtMs,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      dueDateMs: data.dueDateMs.present ? data.dueDateMs.value : this.dueDateMs,
      dueOdometerM: data.dueOdometerM.present
          ? data.dueOdometerM.value
          : this.dueOdometerM,
      isDismissed: data.isDismissed.present
          ? data.isDismissed.value
          : this.isDismissed,
      notifiedAtMs: data.notifiedAtMs.present
          ? data.notifiedAtMs.value
          : this.notifiedAtMs,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('dueDateMs: $dueDateMs, ')
          ..write('dueOdometerM: $dueOdometerM, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('notifiedAtMs: $notifiedAtMs, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    vehicleId,
    type,
    title,
    dueDateMs,
    dueOdometerM,
    isDismissed,
    notifiedAtMs,
    sourceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.vehicleId == this.vehicleId &&
          other.type == this.type &&
          other.title == this.title &&
          other.dueDateMs == this.dueDateMs &&
          other.dueOdometerM == this.dueOdometerM &&
          other.isDismissed == this.isDismissed &&
          other.notifiedAtMs == this.notifiedAtMs &&
          other.sourceId == this.sourceId);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> vehicleId;
  final Value<ReminderType> type;
  final Value<String> title;
  final Value<int?> dueDateMs;
  final Value<int?> dueOdometerM;
  final Value<bool> isDismissed;
  final Value<int?> notifiedAtMs;
  final Value<int?> sourceId;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.dueDateMs = const Value.absent(),
    this.dueOdometerM = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.notifiedAtMs = const Value.absent(),
    this.sourceId = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int vehicleId,
    required ReminderType type,
    required String title,
    this.dueDateMs = const Value.absent(),
    this.dueOdometerM = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.notifiedAtMs = const Value.absent(),
    this.sourceId = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       vehicleId = Value(vehicleId),
       type = Value(type),
       title = Value(title);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? vehicleId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<int>? dueDateMs,
    Expression<int>? dueOdometerM,
    Expression<bool>? isDismissed,
    Expression<int>? notifiedAtMs,
    Expression<int>? sourceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (dueDateMs != null) 'due_date_ms': dueDateMs,
      if (dueOdometerM != null) 'due_odometer_m': dueOdometerM,
      if (isDismissed != null) 'is_dismissed': isDismissed,
      if (notifiedAtMs != null) 'notified_at_ms': notifiedAtMs,
      if (sourceId != null) 'source_id': sourceId,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? vehicleId,
    Value<ReminderType>? type,
    Value<String>? title,
    Value<int?>? dueDateMs,
    Value<int?>? dueOdometerM,
    Value<bool>? isDismissed,
    Value<int?>? notifiedAtMs,
    Value<int?>? sourceId,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      dueDateMs: dueDateMs ?? this.dueDateMs,
      dueOdometerM: dueOdometerM ?? this.dueOdometerM,
      isDismissed: isDismissed ?? this.isDismissed,
      notifiedAtMs: notifiedAtMs ?? this.notifiedAtMs,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueDateMs.present) {
      map['due_date_ms'] = Variable<int>(dueDateMs.value);
    }
    if (dueOdometerM.present) {
      map['due_odometer_m'] = Variable<int>(dueOdometerM.value);
    }
    if (isDismissed.present) {
      map['is_dismissed'] = Variable<bool>(isDismissed.value);
    }
    if (notifiedAtMs.present) {
      map['notified_at_ms'] = Variable<int>(notifiedAtMs.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('dueDateMs: $dueDateMs, ')
          ..write('dueOdometerM: $dueOdometerM, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('notifiedAtMs: $notifiedAtMs, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $FuelEntriesTable fuelEntries = $FuelEntriesTable(this);
  late final $ServiceItemsTable serviceItems = $ServiceItemsTable(this);
  late final $ServiceLogsTable serviceLogs = $ServiceLogsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $RidesTable rides = $RidesTable(this);
  late final $RidePointsTable ridePoints = $RidePointsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final Index idxFuelVehicleOdo = Index(
    'idx_fuel_vehicle_odo',
    'CREATE INDEX idx_fuel_vehicle_odo ON fuel_entries (vehicle_id, odometer_m)',
  );
  late final Index idxFuelVehicleDate = Index(
    'idx_fuel_vehicle_date',
    'CREATE INDEX idx_fuel_vehicle_date ON fuel_entries (vehicle_id, date_ms)',
  );
  late final Index idxServiceItemVehicle = Index(
    'idx_service_item_vehicle',
    'CREATE INDEX idx_service_item_vehicle ON service_items (vehicle_id)',
  );
  late final Index idxServiceLogVehicleDate = Index(
    'idx_service_log_vehicle_date',
    'CREATE INDEX idx_service_log_vehicle_date ON service_logs (vehicle_id, date_ms)',
  );
  late final Index idxServiceLogItem = Index(
    'idx_service_log_item',
    'CREATE INDEX idx_service_log_item ON service_logs (service_item_id)',
  );
  late final Index idxExpenseVehicleDate = Index(
    'idx_expense_vehicle_date',
    'CREATE INDEX idx_expense_vehicle_date ON expenses (vehicle_id, date_ms)',
  );
  late final Index idxRideVehicleStart = Index(
    'idx_ride_vehicle_start',
    'CREATE INDEX idx_ride_vehicle_start ON rides (vehicle_id, start_time_ms)',
  );
  late final Index idxRidePointRideTs = Index(
    'idx_ride_point_ride_ts',
    'CREATE INDEX idx_ride_point_ride_ts ON ride_points (ride_id, timestamp_ms)',
  );
  late final Index idxReminderVehicle = Index(
    'idx_reminder_vehicle',
    'CREATE INDEX idx_reminder_vehicle ON reminders (vehicle_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    fuelEntries,
    serviceItems,
    serviceLogs,
    expenses,
    rides,
    ridePoints,
    reminders,
    idxFuelVehicleOdo,
    idxFuelVehicleDate,
    idxServiceItemVehicle,
    idxServiceLogVehicleDate,
    idxServiceLogItem,
    idxExpenseVehicleDate,
    idxRideVehicleStart,
    idxRidePointRideTs,
    idxReminderVehicle,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fuel_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('service_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('service_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'service_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('service_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rides', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rides',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ride_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      Value<String?> make,
      Value<String?> model,
      Value<int?> year,
      Value<int?> engineCc,
      Value<String?> registrationNo,
      Value<FuelType> fuelType,
      Value<int?> purchaseDateMs,
      Value<int?> purchasePriceMinor,
      Value<int> initialOdometerM,
      Value<int?> currentValueEstimateMinor,
      Value<int?> tankCapacityMl,
      Value<DistanceUnit> distanceUnit,
      Value<VolumeUnit> volumeUnit,
      Value<String> currency,
      Value<bool> isDefault,
      Value<int> colorTag,
      Value<bool> isArchived,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<String?> make,
      Value<String?> model,
      Value<int?> year,
      Value<int?> engineCc,
      Value<String?> registrationNo,
      Value<FuelType> fuelType,
      Value<int?> purchaseDateMs,
      Value<int?> purchasePriceMinor,
      Value<int> initialOdometerM,
      Value<int?> currentValueEstimateMinor,
      Value<int?> tankCapacityMl,
      Value<DistanceUnit> distanceUnit,
      Value<VolumeUnit> volumeUnit,
      Value<String> currency,
      Value<bool> isDefault,
      Value<int> colorTag,
      Value<bool> isArchived,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelEntriesTable, List<FuelEntryRow>>
  _fuelEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelEntries,
    aliasName: 'vehicles__id__fuel_entries__vehicle_id',
  );

  $$FuelEntriesTableProcessedTableManager get fuelEntriesRefs {
    final manager = $$FuelEntriesTableTableManager(
      $_db,
      $_db.fuelEntries,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceItemsTable, List<ServiceItemRow>>
  _serviceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceItems,
    aliasName: 'vehicles__id__service_items__vehicle_id',
  );

  $$ServiceItemsTableProcessedTableManager get serviceItemsRefs {
    final manager = $$ServiceItemsTableTableManager(
      $_db,
      $_db.serviceItems,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceLogsTable, List<ServiceLogRow>>
  _serviceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceLogs,
    aliasName: 'vehicles__id__service_logs__vehicle_id',
  );

  $$ServiceLogsTableProcessedTableManager get serviceLogsRefs {
    final manager = $$ServiceLogsTableTableManager(
      $_db,
      $_db.serviceLogs,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'vehicles__id__expenses__vehicle_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RidesTable, List<RideRow>> _ridesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rides,
    aliasName: 'vehicles__id__rides__vehicle_id',
  );

  $$RidesTableProcessedTableManager get ridesRefs {
    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'vehicles__id__reminders__vehicle_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get engineCc => $composableBuilder(
    column: $table.engineCc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType, FuelType, String> get fuelType =>
      $composableBuilder(
        column: $table.fuelType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get purchaseDateMs => $composableBuilder(
    column: $table.purchaseDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialOdometerM => $composableBuilder(
    column: $table.initialOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentValueEstimateMinor => $composableBuilder(
    column: $table.currentValueEstimateMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tankCapacityMl => $composableBuilder(
    column: $table.tankCapacityMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DistanceUnit, DistanceUnit, String>
  get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<VolumeUnit, VolumeUnit, String>
  get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelEntriesRefs(
    Expression<bool> Function($$FuelEntriesTableFilterComposer f) f,
  ) {
    final $$FuelEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableFilterComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceItemsRefs(
    Expression<bool> Function($$ServiceItemsTableFilterComposer f) f,
  ) {
    final $$ServiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceLogsRefs(
    Expression<bool> Function($$ServiceLogsTableFilterComposer f) f,
  ) {
    final $$ServiceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceLogs,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceLogsTableFilterComposer(
            $db: $db,
            $table: $db.serviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ridesRefs(
    Expression<bool> Function($$RidesTableFilterComposer f) f,
  ) {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get engineCc => $composableBuilder(
    column: $table.engineCc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchaseDateMs => $composableBuilder(
    column: $table.purchaseDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialOdometerM => $composableBuilder(
    column: $table.initialOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentValueEstimateMinor => $composableBuilder(
    column: $table.currentValueEstimateMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tankCapacityMl => $composableBuilder(
    column: $table.tankCapacityMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeUnit => $composableBuilder(
    column: $table.volumeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get engineCc =>
      $composableBuilder(column: $table.engineCc, builder: (column) => column);

  GeneratedColumn<String> get registrationNo => $composableBuilder(
    column: $table.registrationNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FuelType, String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<int> get purchaseDateMs => $composableBuilder(
    column: $table.purchaseDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialOdometerM => $composableBuilder(
    column: $table.initialOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentValueEstimateMinor => $composableBuilder(
    column: $table.currentValueEstimateMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tankCapacityMl => $composableBuilder(
    column: $table.tankCapacityMl,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DistanceUnit, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<VolumeUnit, String> get volumeUnit =>
      $composableBuilder(
        column: $table.volumeUnit,
        builder: (column) => column,
      );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get colorTag =>
      $composableBuilder(column: $table.colorTag, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> fuelEntriesRefs<T extends Object>(
    Expression<T> Function($$FuelEntriesTableAnnotationComposer a) f,
  ) {
    final $$FuelEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> serviceItemsRefs<T extends Object>(
    Expression<T> Function($$ServiceItemsTableAnnotationComposer a) f,
  ) {
    final $$ServiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> serviceLogsRefs<T extends Object>(
    Expression<T> Function($$ServiceLogsTableAnnotationComposer a) f,
  ) {
    final $$ServiceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceLogs,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ridesRefs<T extends Object>(
    Expression<T> Function($$RidesTableAnnotationComposer a) f,
  ) {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehicleRow,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (VehicleRow, $$VehiclesTableReferences),
          VehicleRow,
          PrefetchHooks Function({
            bool fuelEntriesRefs,
            bool serviceItemsRefs,
            bool serviceLogsRefs,
            bool expensesRefs,
            bool ridesRefs,
            bool remindersRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> engineCc = const Value.absent(),
                Value<String?> registrationNo = const Value.absent(),
                Value<FuelType> fuelType = const Value.absent(),
                Value<int?> purchaseDateMs = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
                Value<int> initialOdometerM = const Value.absent(),
                Value<int?> currentValueEstimateMinor = const Value.absent(),
                Value<int?> tankCapacityMl = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<VolumeUnit> volumeUnit = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> colorTag = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                make: make,
                model: model,
                year: year,
                engineCc: engineCc,
                registrationNo: registrationNo,
                fuelType: fuelType,
                purchaseDateMs: purchaseDateMs,
                purchasePriceMinor: purchasePriceMinor,
                initialOdometerM: initialOdometerM,
                currentValueEstimateMinor: currentValueEstimateMinor,
                tankCapacityMl: tankCapacityMl,
                distanceUnit: distanceUnit,
                volumeUnit: volumeUnit,
                currency: currency,
                isDefault: isDefault,
                colorTag: colorTag,
                isArchived: isArchived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> engineCc = const Value.absent(),
                Value<String?> registrationNo = const Value.absent(),
                Value<FuelType> fuelType = const Value.absent(),
                Value<int?> purchaseDateMs = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
                Value<int> initialOdometerM = const Value.absent(),
                Value<int?> currentValueEstimateMinor = const Value.absent(),
                Value<int?> tankCapacityMl = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<VolumeUnit> volumeUnit = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> colorTag = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                make: make,
                model: model,
                year: year,
                engineCc: engineCc,
                registrationNo: registrationNo,
                fuelType: fuelType,
                purchaseDateMs: purchaseDateMs,
                purchasePriceMinor: purchasePriceMinor,
                initialOdometerM: initialOdometerM,
                currentValueEstimateMinor: currentValueEstimateMinor,
                tankCapacityMl: tankCapacityMl,
                distanceUnit: distanceUnit,
                volumeUnit: volumeUnit,
                currency: currency,
                isDefault: isDefault,
                colorTag: colorTag,
                isArchived: isArchived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fuelEntriesRefs = false,
                serviceItemsRefs = false,
                serviceLogsRefs = false,
                expensesRefs = false,
                ridesRefs = false,
                remindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fuelEntriesRefs) db.fuelEntries,
                    if (serviceItemsRefs) db.serviceItems,
                    if (serviceLogsRefs) db.serviceLogs,
                    if (expensesRefs) db.expenses,
                    if (ridesRefs) db.rides,
                    if (remindersRefs) db.reminders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fuelEntriesRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          FuelEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._fuelEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceItemsRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          ServiceItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._serviceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceLogsRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          ServiceLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._serviceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          ExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ridesRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          RideRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._ridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).ridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          VehicleRow,
                          $VehiclesTable,
                          ReminderRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehicleRow,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (VehicleRow, $$VehiclesTableReferences),
      VehicleRow,
      PrefetchHooks Function({
        bool fuelEntriesRefs,
        bool serviceItemsRefs,
        bool serviceLogsRefs,
        bool expensesRefs,
        bool ridesRefs,
        bool remindersRefs,
      })
    >;
typedef $$FuelEntriesTableCreateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      required int dateMs,
      required int odometerM,
      required int volumeMl,
      required int pricePerUnitMinor,
      required int totalCostMinor,
      Value<bool> isFullTank,
      Value<bool> isMissedEntry,
      Value<String?> station,
      Value<String?> notes,
    });
typedef $$FuelEntriesTableUpdateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<int> dateMs,
      Value<int> odometerM,
      Value<int> volumeMl,
      Value<int> pricePerUnitMinor,
      Value<int> totalCostMinor,
      Value<bool> isFullTank,
      Value<bool> isMissedEntry,
      Value<String?> station,
      Value<String?> notes,
    });

final class $$FuelEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FuelEntriesTable, FuelEntryRow> {
  $$FuelEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('fuel_entries__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerM => $composableBuilder(
    column: $table.odometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerUnitMinor => $composableBuilder(
    column: $table.pricePerUnitMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMissedEntry => $composableBuilder(
    column: $table.isMissedEntry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get station => $composableBuilder(
    column: $table.station,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerM => $composableBuilder(
    column: $table.odometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerUnitMinor => $composableBuilder(
    column: $table.pricePerUnitMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMissedEntry => $composableBuilder(
    column: $table.isMissedEntry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get station => $composableBuilder(
    column: $table.station,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get dateMs =>
      $composableBuilder(column: $table.dateMs, builder: (column) => column);

  GeneratedColumn<int> get odometerM =>
      $composableBuilder(column: $table.odometerM, builder: (column) => column);

  GeneratedColumn<int> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<int> get pricePerUnitMinor => $composableBuilder(
    column: $table.pricePerUnitMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMissedEntry => $composableBuilder(
    column: $table.isMissedEntry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get station =>
      $composableBuilder(column: $table.station, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelEntriesTable,
          FuelEntryRow,
          $$FuelEntriesTableFilterComposer,
          $$FuelEntriesTableOrderingComposer,
          $$FuelEntriesTableAnnotationComposer,
          $$FuelEntriesTableCreateCompanionBuilder,
          $$FuelEntriesTableUpdateCompanionBuilder,
          (FuelEntryRow, $$FuelEntriesTableReferences),
          FuelEntryRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$FuelEntriesTableTableManager(_$AppDatabase db, $FuelEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> dateMs = const Value.absent(),
                Value<int> odometerM = const Value.absent(),
                Value<int> volumeMl = const Value.absent(),
                Value<int> pricePerUnitMinor = const Value.absent(),
                Value<int> totalCostMinor = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
                Value<bool> isMissedEntry = const Value.absent(),
                Value<String?> station = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => FuelEntriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                dateMs: dateMs,
                odometerM: odometerM,
                volumeMl: volumeMl,
                pricePerUnitMinor: pricePerUnitMinor,
                totalCostMinor: totalCostMinor,
                isFullTank: isFullTank,
                isMissedEntry: isMissedEntry,
                station: station,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                required int dateMs,
                required int odometerM,
                required int volumeMl,
                required int pricePerUnitMinor,
                required int totalCostMinor,
                Value<bool> isFullTank = const Value.absent(),
                Value<bool> isMissedEntry = const Value.absent(),
                Value<String?> station = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => FuelEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                dateMs: dateMs,
                odometerM: odometerM,
                volumeMl: volumeMl,
                pricePerUnitMinor: pricePerUnitMinor,
                totalCostMinor: totalCostMinor,
                isFullTank: isFullTank,
                isMissedEntry: isMissedEntry,
                station: station,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FuelEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$FuelEntriesTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$FuelEntriesTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FuelEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelEntriesTable,
      FuelEntryRow,
      $$FuelEntriesTableFilterComposer,
      $$FuelEntriesTableOrderingComposer,
      $$FuelEntriesTableAnnotationComposer,
      $$FuelEntriesTableCreateCompanionBuilder,
      $$FuelEntriesTableUpdateCompanionBuilder,
      (FuelEntryRow, $$FuelEntriesTableReferences),
      FuelEntryRow,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$ServiceItemsTableCreateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      required String name,
      Value<int?> intervalM,
      Value<int?> intervalDays,
      Value<int?> lastDoneOdometerM,
      Value<int?> lastDoneDateMs,
      Value<bool> isActive,
      Value<String> iconKey,
      Value<int> sortOrder,
    });
typedef $$ServiceItemsTableUpdateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<String> name,
      Value<int?> intervalM,
      Value<int?> intervalDays,
      Value<int?> lastDoneOdometerM,
      Value<int?> lastDoneDateMs,
      Value<bool> isActive,
      Value<String> iconKey,
      Value<int> sortOrder,
    });

final class $$ServiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceItemsTable, ServiceItemRow> {
  $$ServiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('service_items__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ServiceLogsTable, List<ServiceLogRow>>
  _serviceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceLogs,
    aliasName: 'service_items__id__service_logs__service_item_id',
  );

  $$ServiceLogsTableProcessedTableManager get serviceLogsRefs {
    final manager = $$ServiceLogsTableTableManager(
      $_db,
      $_db.serviceLogs,
    ).filter((f) => f.serviceItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serviceLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalM => $composableBuilder(
    column: $table.intervalM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastDoneOdometerM => $composableBuilder(
    column: $table.lastDoneOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastDoneDateMs => $composableBuilder(
    column: $table.lastDoneDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> serviceLogsRefs(
    Expression<bool> Function($$ServiceLogsTableFilterComposer f) f,
  ) {
    final $$ServiceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceLogs,
      getReferencedColumn: (t) => t.serviceItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceLogsTableFilterComposer(
            $db: $db,
            $table: $db.serviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalM => $composableBuilder(
    column: $table.intervalM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastDoneOdometerM => $composableBuilder(
    column: $table.lastDoneOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastDoneDateMs => $composableBuilder(
    column: $table.lastDoneDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get intervalM =>
      $composableBuilder(column: $table.intervalM, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastDoneOdometerM => $composableBuilder(
    column: $table.lastDoneOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastDoneDateMs => $composableBuilder(
    column: $table.lastDoneDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> serviceLogsRefs<T extends Object>(
    Expression<T> Function($$ServiceLogsTableAnnotationComposer a) f,
  ) {
    final $$ServiceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceLogs,
      getReferencedColumn: (t) => t.serviceItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceItemsTable,
          ServiceItemRow,
          $$ServiceItemsTableFilterComposer,
          $$ServiceItemsTableOrderingComposer,
          $$ServiceItemsTableAnnotationComposer,
          $$ServiceItemsTableCreateCompanionBuilder,
          $$ServiceItemsTableUpdateCompanionBuilder,
          (ServiceItemRow, $$ServiceItemsTableReferences),
          ServiceItemRow,
          PrefetchHooks Function({bool vehicleId, bool serviceLogsRefs})
        > {
  $$ServiceItemsTableTableManager(_$AppDatabase db, $ServiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> intervalM = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> lastDoneOdometerM = const Value.absent(),
                Value<int?> lastDoneDateMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ServiceItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                name: name,
                intervalM: intervalM,
                intervalDays: intervalDays,
                lastDoneOdometerM: lastDoneOdometerM,
                lastDoneDateMs: lastDoneDateMs,
                isActive: isActive,
                iconKey: iconKey,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                required String name,
                Value<int?> intervalM = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<int?> lastDoneOdometerM = const Value.absent(),
                Value<int?> lastDoneDateMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ServiceItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                name: name,
                intervalM: intervalM,
                intervalDays: intervalDays,
                lastDoneOdometerM: lastDoneOdometerM,
                lastDoneDateMs: lastDoneDateMs,
                isActive: isActive,
                iconKey: iconKey,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vehicleId = false, serviceLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (serviceLogsRefs) db.serviceLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable:
                                        $$ServiceItemsTableReferences
                                            ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$ServiceItemsTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (serviceLogsRefs)
                        await $_getPrefetchedData<
                          ServiceItemRow,
                          $ServiceItemsTable,
                          ServiceLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$ServiceItemsTableReferences
                              ._serviceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceItemsTable,
      ServiceItemRow,
      $$ServiceItemsTableFilterComposer,
      $$ServiceItemsTableOrderingComposer,
      $$ServiceItemsTableAnnotationComposer,
      $$ServiceItemsTableCreateCompanionBuilder,
      $$ServiceItemsTableUpdateCompanionBuilder,
      (ServiceItemRow, $$ServiceItemsTableReferences),
      ServiceItemRow,
      PrefetchHooks Function({bool vehicleId, bool serviceLogsRefs})
    >;
typedef $$ServiceLogsTableCreateCompanionBuilder =
    ServiceLogsCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      Value<int?> serviceItemId,
      required String name,
      required int dateMs,
      required int odometerM,
      Value<int> partsCostMinor,
      Value<int> laborCostMinor,
      Value<int> totalCostMinor,
      Value<String?> workshop,
      Value<String?> partBrand,
      Value<String?> notes,
      Value<int?> nextDueOdometerM,
      Value<int?> nextDueDateMs,
    });
typedef $$ServiceLogsTableUpdateCompanionBuilder =
    ServiceLogsCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<int?> serviceItemId,
      Value<String> name,
      Value<int> dateMs,
      Value<int> odometerM,
      Value<int> partsCostMinor,
      Value<int> laborCostMinor,
      Value<int> totalCostMinor,
      Value<String?> workshop,
      Value<String?> partBrand,
      Value<String?> notes,
      Value<int?> nextDueOdometerM,
      Value<int?> nextDueDateMs,
    });

final class $$ServiceLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ServiceLogsTable, ServiceLogRow> {
  $$ServiceLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('service_logs__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ServiceItemsTable _serviceItemIdTable(_$AppDatabase db) => db
      .serviceItems
      .createAlias('service_logs__service_item_id__service_items__id');

  $$ServiceItemsTableProcessedTableManager? get serviceItemId {
    final $_column = $_itemColumn<int>('service_item_id');
    if ($_column == null) return null;
    final manager = $$ServiceItemsTableTableManager(
      $_db,
      $_db.serviceItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ServiceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceLogsTable> {
  $$ServiceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerM => $composableBuilder(
    column: $table.odometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partsCostMinor => $composableBuilder(
    column: $table.partsCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get laborCostMinor => $composableBuilder(
    column: $table.laborCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workshop => $composableBuilder(
    column: $table.workshop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partBrand => $composableBuilder(
    column: $table.partBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueOdometerM => $composableBuilder(
    column: $table.nextDueOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextDueDateMs => $composableBuilder(
    column: $table.nextDueDateMs,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceItemsTableFilterComposer get serviceItemId {
    final $$ServiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceItemId,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceLogsTable> {
  $$ServiceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerM => $composableBuilder(
    column: $table.odometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partsCostMinor => $composableBuilder(
    column: $table.partsCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get laborCostMinor => $composableBuilder(
    column: $table.laborCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workshop => $composableBuilder(
    column: $table.workshop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partBrand => $composableBuilder(
    column: $table.partBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueOdometerM => $composableBuilder(
    column: $table.nextDueOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextDueDateMs => $composableBuilder(
    column: $table.nextDueDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceItemsTableOrderingComposer get serviceItemId {
    final $$ServiceItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceItemId,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableOrderingComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceLogsTable> {
  $$ServiceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get dateMs =>
      $composableBuilder(column: $table.dateMs, builder: (column) => column);

  GeneratedColumn<int> get odometerM =>
      $composableBuilder(column: $table.odometerM, builder: (column) => column);

  GeneratedColumn<int> get partsCostMinor => $composableBuilder(
    column: $table.partsCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get laborCostMinor => $composableBuilder(
    column: $table.laborCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostMinor => $composableBuilder(
    column: $table.totalCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workshop =>
      $composableBuilder(column: $table.workshop, builder: (column) => column);

  GeneratedColumn<String> get partBrand =>
      $composableBuilder(column: $table.partBrand, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get nextDueOdometerM => $composableBuilder(
    column: $table.nextDueOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextDueDateMs => $composableBuilder(
    column: $table.nextDueDateMs,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServiceItemsTableAnnotationComposer get serviceItemId {
    final $$ServiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceItemId,
      referencedTable: $db.serviceItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceLogsTable,
          ServiceLogRow,
          $$ServiceLogsTableFilterComposer,
          $$ServiceLogsTableOrderingComposer,
          $$ServiceLogsTableAnnotationComposer,
          $$ServiceLogsTableCreateCompanionBuilder,
          $$ServiceLogsTableUpdateCompanionBuilder,
          (ServiceLogRow, $$ServiceLogsTableReferences),
          ServiceLogRow,
          PrefetchHooks Function({bool vehicleId, bool serviceItemId})
        > {
  $$ServiceLogsTableTableManager(_$AppDatabase db, $ServiceLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int?> serviceItemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> dateMs = const Value.absent(),
                Value<int> odometerM = const Value.absent(),
                Value<int> partsCostMinor = const Value.absent(),
                Value<int> laborCostMinor = const Value.absent(),
                Value<int> totalCostMinor = const Value.absent(),
                Value<String?> workshop = const Value.absent(),
                Value<String?> partBrand = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> nextDueOdometerM = const Value.absent(),
                Value<int?> nextDueDateMs = const Value.absent(),
              }) => ServiceLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                serviceItemId: serviceItemId,
                name: name,
                dateMs: dateMs,
                odometerM: odometerM,
                partsCostMinor: partsCostMinor,
                laborCostMinor: laborCostMinor,
                totalCostMinor: totalCostMinor,
                workshop: workshop,
                partBrand: partBrand,
                notes: notes,
                nextDueOdometerM: nextDueOdometerM,
                nextDueDateMs: nextDueDateMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                Value<int?> serviceItemId = const Value.absent(),
                required String name,
                required int dateMs,
                required int odometerM,
                Value<int> partsCostMinor = const Value.absent(),
                Value<int> laborCostMinor = const Value.absent(),
                Value<int> totalCostMinor = const Value.absent(),
                Value<String?> workshop = const Value.absent(),
                Value<String?> partBrand = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> nextDueOdometerM = const Value.absent(),
                Value<int?> nextDueDateMs = const Value.absent(),
              }) => ServiceLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                serviceItemId: serviceItemId,
                name: name,
                dateMs: dateMs,
                odometerM: odometerM,
                partsCostMinor: partsCostMinor,
                laborCostMinor: laborCostMinor,
                totalCostMinor: totalCostMinor,
                workshop: workshop,
                partBrand: partBrand,
                notes: notes,
                nextDueOdometerM: nextDueOdometerM,
                nextDueDateMs: nextDueDateMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, serviceItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$ServiceLogsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$ServiceLogsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (serviceItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.serviceItemId,
                                referencedTable: $$ServiceLogsTableReferences
                                    ._serviceItemIdTable(db),
                                referencedColumn: $$ServiceLogsTableReferences
                                    ._serviceItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ServiceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceLogsTable,
      ServiceLogRow,
      $$ServiceLogsTableFilterComposer,
      $$ServiceLogsTableOrderingComposer,
      $$ServiceLogsTableAnnotationComposer,
      $$ServiceLogsTableCreateCompanionBuilder,
      $$ServiceLogsTableUpdateCompanionBuilder,
      (ServiceLogRow, $$ServiceLogsTableReferences),
      ServiceLogRow,
      PrefetchHooks Function({bool vehicleId, bool serviceItemId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      required ExpenseCategory category,
      required int dateMs,
      required int amountMinor,
      Value<String?> notes,
      Value<int?> validFromMs,
      Value<int?> validUntilMs,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<ExpenseCategory> category,
      Value<int> dateMs,
      Value<int> amountMinor,
      Value<String?> notes,
      Value<int?> validFromMs,
      Value<int?> validUntilMs,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('expenses__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseCategory, ExpenseCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validFromMs => $composableBuilder(
    column: $table.validFromMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validUntilMs => $composableBuilder(
    column: $table.validUntilMs,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateMs => $composableBuilder(
    column: $table.dateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validFromMs => $composableBuilder(
    column: $table.validFromMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validUntilMs => $composableBuilder(
    column: $table.validUntilMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get dateMs =>
      $composableBuilder(column: $table.dateMs, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get validFromMs => $composableBuilder(
    column: $table.validFromMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get validUntilMs => $composableBuilder(
    column: $table.validUntilMs,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseRow, $$ExpensesTableReferences),
          ExpenseRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<ExpenseCategory> category = const Value.absent(),
                Value<int> dateMs = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> validFromMs = const Value.absent(),
                Value<int?> validUntilMs = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                category: category,
                dateMs: dateMs,
                amountMinor: amountMinor,
                notes: notes,
                validFromMs: validFromMs,
                validUntilMs: validUntilMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                required ExpenseCategory category,
                required int dateMs,
                required int amountMinor,
                Value<String?> notes = const Value.absent(),
                Value<int?> validFromMs = const Value.absent(),
                Value<int?> validUntilMs = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                category: category,
                dateMs: dateMs,
                amountMinor: amountMinor,
                notes: notes,
                validFromMs: validFromMs,
                validUntilMs: validUntilMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$ExpensesTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, $$ExpensesTableReferences),
      ExpenseRow,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$RidesTableCreateCompanionBuilder =
    RidesCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      required int startTimeMs,
      Value<int?> endTimeMs,
      Value<int> distanceMeters,
      Value<int> movingSeconds,
      Value<int> totalSeconds,
      Value<double> avgSpeed,
      Value<double> maxSpeed,
      Value<int?> startOdometerM,
      Value<int?> endOdometerM,
      Value<String?> title,
      Value<String?> notes,
      Value<bool> isComplete,
    });
typedef $$RidesTableUpdateCompanionBuilder =
    RidesCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<int> startTimeMs,
      Value<int?> endTimeMs,
      Value<int> distanceMeters,
      Value<int> movingSeconds,
      Value<int> totalSeconds,
      Value<double> avgSpeed,
      Value<double> maxSpeed,
      Value<int?> startOdometerM,
      Value<int?> endOdometerM,
      Value<String?> title,
      Value<String?> notes,
      Value<bool> isComplete,
    });

final class $$RidesTableReferences
    extends BaseReferences<_$AppDatabase, $RidesTable, RideRow> {
  $$RidesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('rides__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RidePointsTable, List<RidePointRow>>
  _ridePointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ridePoints,
    aliasName: 'rides__id__ride_points__ride_id',
  );

  $$RidePointsTableProcessedTableManager get ridePointsRefs {
    final manager = $$RidePointsTableTableManager(
      $_db,
      $_db.ridePoints,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ridePointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RidesTableFilterComposer extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingSeconds => $composableBuilder(
    column: $table.movingSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeed => $composableBuilder(
    column: $table.avgSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startOdometerM => $composableBuilder(
    column: $table.startOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endOdometerM => $composableBuilder(
    column: $table.endOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ridePointsRefs(
    Expression<bool> Function($$RidePointsTableFilterComposer f) f,
  ) {
    final $$RidePointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ridePoints,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidePointsTableFilterComposer(
            $db: $db,
            $table: $db.ridePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RidesTableOrderingComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTimeMs => $composableBuilder(
    column: $table.endTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingSeconds => $composableBuilder(
    column: $table.movingSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeed => $composableBuilder(
    column: $table.avgSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startOdometerM => $composableBuilder(
    column: $table.startOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endOdometerM => $composableBuilder(
    column: $table.endOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RidesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get startTimeMs => $composableBuilder(
    column: $table.startTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endTimeMs =>
      $composableBuilder(column: $table.endTimeMs, builder: (column) => column);

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingSeconds => $composableBuilder(
    column: $table.movingSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSeconds => $composableBuilder(
    column: $table.totalSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeed =>
      $composableBuilder(column: $table.avgSpeed, builder: (column) => column);

  GeneratedColumn<double> get maxSpeed =>
      $composableBuilder(column: $table.maxSpeed, builder: (column) => column);

  GeneratedColumn<int> get startOdometerM => $composableBuilder(
    column: $table.startOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endOdometerM => $composableBuilder(
    column: $table.endOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ridePointsRefs<T extends Object>(
    Expression<T> Function($$RidePointsTableAnnotationComposer a) f,
  ) {
    final $$RidePointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ridePoints,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidePointsTableAnnotationComposer(
            $db: $db,
            $table: $db.ridePoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RidesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RidesTable,
          RideRow,
          $$RidesTableFilterComposer,
          $$RidesTableOrderingComposer,
          $$RidesTableAnnotationComposer,
          $$RidesTableCreateCompanionBuilder,
          $$RidesTableUpdateCompanionBuilder,
          (RideRow, $$RidesTableReferences),
          RideRow,
          PrefetchHooks Function({bool vehicleId, bool ridePointsRefs})
        > {
  $$RidesTableTableManager(_$AppDatabase db, $RidesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> startTimeMs = const Value.absent(),
                Value<int?> endTimeMs = const Value.absent(),
                Value<int> distanceMeters = const Value.absent(),
                Value<int> movingSeconds = const Value.absent(),
                Value<int> totalSeconds = const Value.absent(),
                Value<double> avgSpeed = const Value.absent(),
                Value<double> maxSpeed = const Value.absent(),
                Value<int?> startOdometerM = const Value.absent(),
                Value<int?> endOdometerM = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
              }) => RidesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                distanceMeters: distanceMeters,
                movingSeconds: movingSeconds,
                totalSeconds: totalSeconds,
                avgSpeed: avgSpeed,
                maxSpeed: maxSpeed,
                startOdometerM: startOdometerM,
                endOdometerM: endOdometerM,
                title: title,
                notes: notes,
                isComplete: isComplete,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                required int startTimeMs,
                Value<int?> endTimeMs = const Value.absent(),
                Value<int> distanceMeters = const Value.absent(),
                Value<int> movingSeconds = const Value.absent(),
                Value<int> totalSeconds = const Value.absent(),
                Value<double> avgSpeed = const Value.absent(),
                Value<double> maxSpeed = const Value.absent(),
                Value<int?> startOdometerM = const Value.absent(),
                Value<int?> endOdometerM = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
              }) => RidesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                startTimeMs: startTimeMs,
                endTimeMs: endTimeMs,
                distanceMeters: distanceMeters,
                movingSeconds: movingSeconds,
                totalSeconds: totalSeconds,
                avgSpeed: avgSpeed,
                maxSpeed: maxSpeed,
                startOdometerM: startOdometerM,
                endOdometerM: endOdometerM,
                title: title,
                notes: notes,
                isComplete: isComplete,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RidesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, ridePointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ridePointsRefs) db.ridePoints],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$RidesTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$RidesTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ridePointsRefs)
                    await $_getPrefetchedData<
                      RideRow,
                      $RidesTable,
                      RidePointRow
                    >(
                      currentTable: table,
                      referencedTable: $$RidesTableReferences
                          ._ridePointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RidesTableReferences(db, table, p0).ridePointsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rideId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RidesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RidesTable,
      RideRow,
      $$RidesTableFilterComposer,
      $$RidesTableOrderingComposer,
      $$RidesTableAnnotationComposer,
      $$RidesTableCreateCompanionBuilder,
      $$RidesTableUpdateCompanionBuilder,
      (RideRow, $$RidesTableReferences),
      RideRow,
      PrefetchHooks Function({bool vehicleId, bool ridePointsRefs})
    >;
typedef $$RidePointsTableCreateCompanionBuilder =
    RidePointsCompanion Function({
      Value<int> id,
      required int rideId,
      required double lat,
      required double lng,
      required int timestampMs,
      Value<double?> speed,
      Value<double?> accuracy,
      Value<double?> altitude,
      Value<bool> isGapStart,
    });
typedef $$RidePointsTableUpdateCompanionBuilder =
    RidePointsCompanion Function({
      Value<int> id,
      Value<int> rideId,
      Value<double> lat,
      Value<double> lng,
      Value<int> timestampMs,
      Value<double?> speed,
      Value<double?> accuracy,
      Value<double?> altitude,
      Value<bool> isGapStart,
    });

final class $$RidePointsTableReferences
    extends BaseReferences<_$AppDatabase, $RidePointsTable, RidePointRow> {
  $$RidePointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RidesTable _rideIdTable(_$AppDatabase db) =>
      db.rides.createAlias('ride_points__ride_id__rides__id');

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<int>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RidePointsTableFilterComposer
    extends Composer<_$AppDatabase, $RidePointsTable> {
  $$RidePointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGapStart => $composableBuilder(
    column: $table.isGapStart,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RidePointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RidePointsTable> {
  $$RidePointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGapStart => $composableBuilder(
    column: $table.isGapStart,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RidePointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RidePointsTable> {
  $$RidePointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<bool> get isGapStart => $composableBuilder(
    column: $table.isGapStart,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RidePointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RidePointsTable,
          RidePointRow,
          $$RidePointsTableFilterComposer,
          $$RidePointsTableOrderingComposer,
          $$RidePointsTableAnnotationComposer,
          $$RidePointsTableCreateCompanionBuilder,
          $$RidePointsTableUpdateCompanionBuilder,
          (RidePointRow, $$RidePointsTableReferences),
          RidePointRow,
          PrefetchHooks Function({bool rideId})
        > {
  $$RidePointsTableTableManager(_$AppDatabase db, $RidePointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RidePointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RidePointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RidePointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rideId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<bool> isGapStart = const Value.absent(),
              }) => RidePointsCompanion(
                id: id,
                rideId: rideId,
                lat: lat,
                lng: lng,
                timestampMs: timestampMs,
                speed: speed,
                accuracy: accuracy,
                altitude: altitude,
                isGapStart: isGapStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rideId,
                required double lat,
                required double lng,
                required int timestampMs,
                Value<double?> speed = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<bool> isGapStart = const Value.absent(),
              }) => RidePointsCompanion.insert(
                id: id,
                rideId: rideId,
                lat: lat,
                lng: lng,
                timestampMs: timestampMs,
                speed: speed,
                accuracy: accuracy,
                altitude: altitude,
                isGapStart: isGapStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RidePointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rideId,
                                referencedTable: $$RidePointsTableReferences
                                    ._rideIdTable(db),
                                referencedColumn: $$RidePointsTableReferences
                                    ._rideIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RidePointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RidePointsTable,
      RidePointRow,
      $$RidePointsTableFilterComposer,
      $$RidePointsTableOrderingComposer,
      $$RidePointsTableAnnotationComposer,
      $$RidePointsTableCreateCompanionBuilder,
      $$RidePointsTableUpdateCompanionBuilder,
      (RidePointRow, $$RidePointsTableReferences),
      RidePointRow,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int vehicleId,
      required ReminderType type,
      required String title,
      Value<int?> dueDateMs,
      Value<int?> dueOdometerM,
      Value<bool> isDismissed,
      Value<int?> notifiedAtMs,
      Value<int?> sourceId,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> vehicleId,
      Value<ReminderType> type,
      Value<String> title,
      Value<int?> dueDateMs,
      Value<int?> dueOdometerM,
      Value<bool> isDismissed,
      Value<int?> notifiedAtMs,
      Value<int?> sourceId,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('reminders__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDateMs => $composableBuilder(
    column: $table.dueDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueOdometerM => $composableBuilder(
    column: $table.dueOdometerM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notifiedAtMs => $composableBuilder(
    column: $table.notifiedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDateMs => $composableBuilder(
    column: $table.dueDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueOdometerM => $composableBuilder(
    column: $table.dueOdometerM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notifiedAtMs => $composableBuilder(
    column: $table.notifiedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dueDateMs =>
      $composableBuilder(column: $table.dueDateMs, builder: (column) => column);

  GeneratedColumn<int> get dueOdometerM => $composableBuilder(
    column: $table.dueOdometerM,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notifiedAtMs => $composableBuilder(
    column: $table.notifiedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (ReminderRow, $$RemindersTableReferences),
          ReminderRow,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<ReminderType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> dueDateMs = const Value.absent(),
                Value<int?> dueOdometerM = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<int?> notifiedAtMs = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                type: type,
                title: title,
                dueDateMs: dueDateMs,
                dueOdometerM: dueOdometerM,
                isDismissed: isDismissed,
                notifiedAtMs: notifiedAtMs,
                sourceId: sourceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int vehicleId,
                required ReminderType type,
                required String title,
                Value<int?> dueDateMs = const Value.absent(),
                Value<int?> dueOdometerM = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<int?> notifiedAtMs = const Value.absent(),
                Value<int?> sourceId = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                vehicleId: vehicleId,
                type: type,
                title: title,
                dueDateMs: dueDateMs,
                dueOdometerM: dueOdometerM,
                isDismissed: isDismissed,
                notifiedAtMs: notifiedAtMs,
                sourceId: sourceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$RemindersTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (ReminderRow, $$RemindersTableReferences),
      ReminderRow,
      PrefetchHooks Function({bool vehicleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$FuelEntriesTableTableManager get fuelEntries =>
      $$FuelEntriesTableTableManager(_db, _db.fuelEntries);
  $$ServiceItemsTableTableManager get serviceItems =>
      $$ServiceItemsTableTableManager(_db, _db.serviceItems);
  $$ServiceLogsTableTableManager get serviceLogs =>
      $$ServiceLogsTableTableManager(_db, _db.serviceLogs);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$RidesTableTableManager get rides =>
      $$RidesTableTableManager(_db, _db.rides);
  $$RidePointsTableTableManager get ridePoints =>
      $$RidePointsTableTableManager(_db, _db.ridePoints);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
