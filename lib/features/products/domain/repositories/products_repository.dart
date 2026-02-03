import '../entities/product_entity.dart';

/// Products repository interface
abstract class ProductsRepository {
  Future<List<ProductEntity>> getProducts();
  Future<List<ProductEntity>> searchProducts(String query);
  Future<List<ProductEntity>> getProductsByStore(String storeId);
  Future<List<ProductEntity>> getProductsByCategory(String category);
}
