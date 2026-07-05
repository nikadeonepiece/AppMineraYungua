// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncMetadataLocalCollection on Isar {
  IsarCollection<SyncMetadataLocal> get syncMetadataLocals => this.collection();
}

const SyncMetadataLocalSchema = CollectionSchema(
  name: r'SyncMetadataLocal',
  id: -4685374845643113556,
  properties: {
    r'entity': PropertySchema(
      id: 0,
      name: r'entity',
      type: IsarType.string,
    ),
    r'lastSync': PropertySchema(
      id: 1,
      name: r'lastSync',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _syncMetadataLocalEstimateSize,
  serialize: _syncMetadataLocalSerialize,
  deserialize: _syncMetadataLocalDeserialize,
  deserializeProp: _syncMetadataLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'entity': IndexSchema(
      id: -5285054254130720380,
      name: r'entity',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'entity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncMetadataLocalGetId,
  getLinks: _syncMetadataLocalGetLinks,
  attach: _syncMetadataLocalAttach,
  version: '3.1.0+1',
);

int _syncMetadataLocalEstimateSize(
  SyncMetadataLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entity.length * 3;
  return bytesCount;
}

void _syncMetadataLocalSerialize(
  SyncMetadataLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entity);
  writer.writeDateTime(offsets[1], object.lastSync);
}

SyncMetadataLocal _syncMetadataLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMetadataLocal();
  object.entity = reader.readString(offsets[0]);
  object.id = id;
  object.lastSync = reader.readDateTimeOrNull(offsets[1]);
  return object;
}

P _syncMetadataLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetadataLocalGetId(SyncMetadataLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncMetadataLocalGetLinks(
    SyncMetadataLocal object) {
  return [];
}

void _syncMetadataLocalAttach(
    IsarCollection<dynamic> col, Id id, SyncMetadataLocal object) {
  object.id = id;
}

extension SyncMetadataLocalByIndex on IsarCollection<SyncMetadataLocal> {
  Future<SyncMetadataLocal?> getByEntity(String entity) {
    return getByIndex(r'entity', [entity]);
  }

  SyncMetadataLocal? getByEntitySync(String entity) {
    return getByIndexSync(r'entity', [entity]);
  }

  Future<bool> deleteByEntity(String entity) {
    return deleteByIndex(r'entity', [entity]);
  }

  bool deleteByEntitySync(String entity) {
    return deleteByIndexSync(r'entity', [entity]);
  }

  Future<List<SyncMetadataLocal?>> getAllByEntity(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return getAllByIndex(r'entity', values);
  }

  List<SyncMetadataLocal?> getAllByEntitySync(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entity', values);
  }

  Future<int> deleteAllByEntity(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entity', values);
  }

  int deleteAllByEntitySync(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entity', values);
  }

  Future<Id> putByEntity(SyncMetadataLocal object) {
    return putByIndex(r'entity', object);
  }

  Id putByEntitySync(SyncMetadataLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'entity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntity(List<SyncMetadataLocal> objects) {
    return putAllByIndex(r'entity', objects);
  }

  List<Id> putAllByEntitySync(List<SyncMetadataLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entity', objects, saveLinks: saveLinks);
  }
}

extension SyncMetadataLocalQueryWhereSort
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QWhere> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetadataLocalQueryWhere
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QWhereClause> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      entityEqualTo(String entity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entity',
        value: [entity],
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterWhereClause>
      entityNotEqualTo(String entity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [entity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [entity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncMetadataLocalQueryFilter
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QFilterCondition> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
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

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSync',
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSync',
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSync',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSync',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSync',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterFilterCondition>
      lastSyncBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSync',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncMetadataLocalQueryObject
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QFilterCondition> {}

extension SyncMetadataLocalQueryLinks
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QFilterCondition> {}

extension SyncMetadataLocalQuerySortBy
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QSortBy> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      sortByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      sortByLastSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.desc);
    });
  }
}

extension SyncMetadataLocalQuerySortThenBy
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QSortThenBy> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      thenByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.asc);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QAfterSortBy>
      thenByLastSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSync', Sort.desc);
    });
  }
}

extension SyncMetadataLocalQueryWhereDistinct
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QDistinct> {
  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QDistinct>
      distinctByEntity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QDistinct>
      distinctByLastSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSync');
    });
  }
}

extension SyncMetadataLocalQueryProperty
    on QueryBuilder<SyncMetadataLocal, SyncMetadataLocal, QQueryProperty> {
  QueryBuilder<SyncMetadataLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncMetadataLocal, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<SyncMetadataLocal, DateTime?, QQueryOperations>
      lastSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSync');
    });
  }
}
