import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_firebase_datasource.dart';

/// Products repository implementation
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsFirebaseDatasource _datasource;

  ProductsRepositoryImpl(this._datasource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await _datasource.getProducts();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return await _datasource.searchProducts(query);
  }

  @override
  Future<List<ProductEntity>> getProductsByStore(String storeId) async {
    return await _datasource.getProductsByStore(storeId);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    return await _datasource.getProductsByCategory(category);
  }
}
