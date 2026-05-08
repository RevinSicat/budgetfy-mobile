// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_dao.dart';

// ignore_for_file: type=lint
mixin _$SubcategoryDaoMixin on DatabaseAccessor<LocalDatabase> {
  $SubcategoriesTable get subcategories => attachedDatabase.subcategories;
  SubcategoryDaoManager get managers => SubcategoryDaoManager(this);
}

class SubcategoryDaoManager {
  final _$SubcategoryDaoMixin _db;
  SubcategoryDaoManager(this._db);
  $$SubcategoriesTableTableManager get subcategories =>
      $$SubcategoriesTableTableManager(_db.attachedDatabase, _db.subcategories);
}
