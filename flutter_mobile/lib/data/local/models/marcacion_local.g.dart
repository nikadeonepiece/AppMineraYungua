// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marcacion_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMarcacionLocalCollection on Isar {
  IsarCollection<MarcacionLocal> get marcacionLocals => this.collection();
}

const MarcacionLocalSchema = CollectionSchema(
  name: r'MarcacionLocal',
  id: 6508599788395110539,
  properties: {
    r'backoffUntil': PropertySchema(
      id: 0,
      name: r'backoffUntil',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 2,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'empleadoId': PropertySchema(
      id: 3,
      name: r'empleadoId',
      type: IsarType.long,
    ),
    r'empleadoUuid': PropertySchema(
      id: 4,
      name: r'empleadoUuid',
      type: IsarType.string,
    ),
    r'fechaHora': PropertySchema(
      id: 5,
      name: r'fechaHora',
      type: IsarType.dateTime,
    ),
    r'fotoPath': PropertySchema(
      id: 6,
      name: r'fotoPath',
      type: IsarType.string,
    ),
    r'lastUploadError': PropertySchema(
      id: 7,
      name: r'lastUploadError',
      type: IsarType.string,
    ),
    r'latitud': PropertySchema(
      id: 8,
      name: r'latitud',
      type: IsarType.double,
    ),
    r'longitud': PropertySchema(
      id: 9,
      name: r'longitud',
      type: IsarType.double,
    ),
    r'metodo': PropertySchema(
      id: 10,
      name: r'metodo',
      type: IsarType.string,
    ),
    r'nonce': PropertySchema(
      id: 11,
      name: r'nonce',
      type: IsarType.string,
    ),
    r'payloadHash': PropertySchema(
      id: 12,
      name: r'payloadHash',
      type: IsarType.string,
    ),
    r'requestSignature': PropertySchema(
      id: 13,
      name: r'requestSignature',
      type: IsarType.string,
    ),
    r'requestTimestampMs': PropertySchema(
      id: 14,
      name: r'requestTimestampMs',
      type: IsarType.long,
    ),
    r'retryCount': PropertySchema(
      id: 15,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'serverId': PropertySchema(
      id: 16,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'syncStatus': PropertySchema(
      id: 17,
      name: r'syncStatus',
      type: IsarType.byte,
      enumMap: _MarcacionLocalsyncStatusEnumValueMap,
    ),
    r'syncedAt': PropertySchema(
      id: 18,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'tipo': PropertySchema(
      id: 19,
      name: r'tipo',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 20,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _marcacionLocalEstimateSize,
  serialize: _marcacionLocalSerialize,
  deserialize: _marcacionLocalDeserialize,
  deserializeProp: _marcacionLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _marcacionLocalGetId,
  getLinks: _marcacionLocalGetLinks,
  attach: _marcacionLocalAttach,
  version: '3.1.0+1',
);

int _marcacionLocalEstimateSize(
  MarcacionLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.empleadoUuid.length * 3;
  {
    final value = object.fotoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lastUploadError.length * 3;
  bytesCount += 3 + object.metodo.length * 3;
  bytesCount += 3 + object.nonce.length * 3;
  bytesCount += 3 + object.payloadHash.length * 3;
  bytesCount += 3 + object.requestSignature.length * 3;
  bytesCount += 3 + object.tipo.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _marcacionLocalSerialize(
  MarcacionLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.backoffUntil);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeLong(offsets[3], object.empleadoId);
  writer.writeString(offsets[4], object.empleadoUuid);
  writer.writeDateTime(offsets[5], object.fechaHora);
  writer.writeString(offsets[6], object.fotoPath);
  writer.writeString(offsets[7], object.lastUploadError);
  writer.writeDouble(offsets[8], object.latitud);
  writer.writeDouble(offsets[9], object.longitud);
  writer.writeString(offsets[10], object.metodo);
  writer.writeString(offsets[11], object.nonce);
  writer.writeString(offsets[12], object.payloadHash);
  writer.writeString(offsets[13], object.requestSignature);
  writer.writeLong(offsets[14], object.requestTimestampMs);
  writer.writeLong(offsets[15], object.retryCount);
  writer.writeLong(offsets[16], object.serverId);
  writer.writeByte(offsets[17], object.syncStatus.index);
  writer.writeDateTime(offsets[18], object.syncedAt);
  writer.writeString(offsets[19], object.tipo);
  writer.writeString(offsets[20], object.uuid);
}

MarcacionLocal _marcacionLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MarcacionLocal();
  object.backoffUntil = reader.readDateTimeOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.deviceId = reader.readString(offsets[2]);
  object.empleadoId = reader.readLong(offsets[3]);
  object.empleadoUuid = reader.readString(offsets[4]);
  object.fechaHora = reader.readDateTime(offsets[5]);
  object.fotoPath = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.lastUploadError = reader.readString(offsets[7]);
  object.latitud = reader.readDoubleOrNull(offsets[8]);
  object.longitud = reader.readDoubleOrNull(offsets[9]);
  object.metodo = reader.readString(offsets[10]);
  object.nonce = reader.readString(offsets[11]);
  object.payloadHash = reader.readString(offsets[12]);
  object.requestSignature = reader.readString(offsets[13]);
  object.requestTimestampMs = reader.readLong(offsets[14]);
  object.retryCount = reader.readLong(offsets[15]);
  object.serverId = reader.readLongOrNull(offsets[16]);
  object.syncStatus = _MarcacionLocalsyncStatusValueEnumMap[
          reader.readByteOrNull(offsets[17])] ??
      SyncStatus.pending;
  object.syncedAt = reader.readDateTimeOrNull(offsets[18]);
  object.tipo = reader.readString(offsets[19]);
  object.uuid = reader.readString(offsets[20]);
  return object;
}

P _marcacionLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (_MarcacionLocalsyncStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MarcacionLocalsyncStatusEnumValueMap = {
  'pending': 0,
  'syncing': 1,
  'synced': 2,
  'failed': 3,
};
const _MarcacionLocalsyncStatusValueEnumMap = {
  0: SyncStatus.pending,
  1: SyncStatus.syncing,
  2: SyncStatus.synced,
  3: SyncStatus.failed,
};

Id _marcacionLocalGetId(MarcacionLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _marcacionLocalGetLinks(MarcacionLocal object) {
  return [];
}

void _marcacionLocalAttach(
    IsarCollection<dynamic> col, Id id, MarcacionLocal object) {
  object.id = id;
}

extension MarcacionLocalByIndex on IsarCollection<MarcacionLocal> {
  Future<MarcacionLocal?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  MarcacionLocal? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<MarcacionLocal?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<MarcacionLocal?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(MarcacionLocal object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(MarcacionLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<MarcacionLocal> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<MarcacionLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension MarcacionLocalQueryWhereSort
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QWhere> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MarcacionLocalQueryWhere
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QWhereClause> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MarcacionLocalQueryFilter
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QFilterCondition> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'backoffUntil',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'backoffUntil',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'backoffUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'backoffUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'backoffUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      backoffUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'backoffUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empleadoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empleadoUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empleadoUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empleadoUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      empleadoUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empleadoUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fechaHoraEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fechaHoraGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fechaHoraLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaHora',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fechaHoraBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaHora',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fotoPath',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fotoPath',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fotoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fotoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      fotoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUploadError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastUploadError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastUploadError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUploadError',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      lastUploadErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastUploadError',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitud',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitud',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      latitudBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitud',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitud',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitud',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitud',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      longitudBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitud',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metodo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodo',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      metodoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metodo',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nonce',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nonce',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nonce',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nonce',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      nonceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nonce',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payloadHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payloadHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payloadHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadHash',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      payloadHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payloadHash',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestSignature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestSignature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestSignatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestTimestampMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestTimestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestTimestampMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestTimestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestTimestampMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestTimestampMs',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      requestTimestampMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestTimestampMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      serverIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncStatusEqualTo(SyncStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncStatusGreaterThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncStatusLessThan(
    SyncStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncStatusBetween(
    SyncStatus lower,
    SyncStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      tipoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipo',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension MarcacionLocalQueryObject
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QFilterCondition> {}

extension MarcacionLocalQueryLinks
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QFilterCondition> {}

extension MarcacionLocalQuerySortBy
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QSortBy> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByBackoffUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backoffUntil', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByBackoffUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backoffUntil', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByEmpleadoUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoUuid', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByEmpleadoUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoUuid', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByFechaHoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByFotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoPath', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByFotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoPath', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByLastUploadError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUploadError', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByLastUploadErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUploadError', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByLatitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitud', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByLatitudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitud', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByLongitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitud', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByLongitudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitud', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByNonce() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nonce', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByNonceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nonce', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByPayloadHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadHash', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByPayloadHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadHash', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRequestSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestSignature', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRequestSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestSignature', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRequestTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTimestampMs', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRequestTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTimestampMs', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MarcacionLocalQuerySortThenBy
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QSortThenBy> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByBackoffUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backoffUntil', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByBackoffUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backoffUntil', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByEmpleadoUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoUuid', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByEmpleadoUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoUuid', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByFechaHoraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaHora', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByFotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoPath', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByFotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoPath', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByLastUploadError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUploadError', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByLastUploadErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUploadError', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByLatitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitud', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByLatitudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitud', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByLongitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitud', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByLongitudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitud', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByNonce() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nonce', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByNonceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nonce', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByPayloadHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadHash', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByPayloadHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadHash', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRequestSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestSignature', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRequestSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestSignature', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRequestTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTimestampMs', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRequestTimestampMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestTimestampMs', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByTipo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByTipoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipo', Sort.desc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension MarcacionLocalQueryWhereDistinct
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> {
  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByBackoffUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backoffUntil');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleadoId');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByEmpleadoUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleadoUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByFechaHora() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaHora');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByFotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fotoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByLastUploadError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUploadError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByLatitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitud');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByLongitud() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitud');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByMetodo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByNonce(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nonce', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByPayloadHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByRequestSignature({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestSignature',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByRequestTimestampMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestTimestampMs');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct>
      distinctBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByTipo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MarcacionLocal, MarcacionLocal, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension MarcacionLocalQueryProperty
    on QueryBuilder<MarcacionLocal, MarcacionLocal, QQueryProperty> {
  QueryBuilder<MarcacionLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MarcacionLocal, DateTime?, QQueryOperations>
      backoffUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backoffUntil');
    });
  }

  QueryBuilder<MarcacionLocal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<MarcacionLocal, int, QQueryOperations> empleadoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleadoId');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations>
      empleadoUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleadoUuid');
    });
  }

  QueryBuilder<MarcacionLocal, DateTime, QQueryOperations> fechaHoraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaHora');
    });
  }

  QueryBuilder<MarcacionLocal, String?, QQueryOperations> fotoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fotoPath');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations>
      lastUploadErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUploadError');
    });
  }

  QueryBuilder<MarcacionLocal, double?, QQueryOperations> latitudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitud');
    });
  }

  QueryBuilder<MarcacionLocal, double?, QQueryOperations> longitudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitud');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> metodoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodo');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> nonceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nonce');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> payloadHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadHash');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations>
      requestSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestSignature');
    });
  }

  QueryBuilder<MarcacionLocal, int, QQueryOperations>
      requestTimestampMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestTimestampMs');
    });
  }

  QueryBuilder<MarcacionLocal, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<MarcacionLocal, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<MarcacionLocal, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<MarcacionLocal, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> tipoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipo');
    });
  }

  QueryBuilder<MarcacionLocal, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
