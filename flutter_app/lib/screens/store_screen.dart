import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import 'product_detail_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  ProductCategory _selectedCategory = ProductCategory.all;

  final Set<String> _ownedProductIds = {'glove-1'};

  static final List<Product> _sampleProducts = [
    Product(
      id: 'bat-1',
      name: 'Vllow Pro X1',
      subtitle: 'Grade 1+ English Willow',
      category: ProductCategory.bats,
      priceCoins: 2500,
      imageURL: 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400',
      woodType: 'English Willow Grade 1+',
      weight: '2lb 8oz',
      balance: 'Mid-Low',
      handleGrip: 'Octopus',
      powerRating: 92,
      description: 'Handcrafted from premium Grade 1+ English Willow with massive edges and a powerful profile.',
    ),
    Product(
      id: 'bat-2',
      name: 'Shadow Blade V7',
      subtitle: 'Kashmir Willow Power',
      category: ProductCategory.bats,
      priceCoins: 1800,
      imageURL: 'https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=400',
      woodType: 'Kashmir Willow',
      weight: '2lb 9oz',
      balance: 'Mid',
      handleGrip: 'Singapore',
      powerRating: 85,
      description: 'Explosive hitting power from carefully selected Kashmir Willow.',
    ),
    Product(
      id: 'glove-1',
      name: 'Stealth Guard Pro',
      subtitle: 'Premium Batting Gloves',
      category: ProductCategory.gloves,
      priceCoins: 800,
      imageURL: 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=400',
      powerRating: 78,
      description: 'Lightweight protection with superior grip technology.',
    ),
    Product(
      id: 'protect-1',
      name: 'Fortress Pads Elite',
      subtitle: 'Pro-Level Leg Guards',
      category: ProductCategory.protective,
      priceCoins: 1200,
      imageURL: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400',
      powerRating: 88,
      description: 'Ultra-lightweight pads with maximum impact absorption.',
    ),
    Product(
      id: 'apparel-1',
      name: 'Vllow Dugout Jersey',
      subtitle: 'Moisture-Wicking Tech',
      category: ProductCategory.apparel,
      priceCoins: 600,
      imageURL: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400',
      powerRating: 70,
      description: 'Official team jersey with advanced moisture management.',
    ),
    Product(
      id: 'glove-2',
      name: 'Keeper X1 Gloves',
      subtitle: 'WK Inner + Outer Set',
      category: ProductCategory.gloves,
      priceCoins: 950,
      imageURL: 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=400',
      powerRating: 82,
      description: 'Professional wicketkeeping gloves with webbed fingers.',
    ),
  ];

  List<Product> get _filteredProducts {
    if (_selectedCategory == ProductCategory.all) return _sampleProducts;
    return _sampleProducts.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final firstBat = _sampleProducts.firstWhere(
          (p) => p.category == ProductCategory.bats,
        );
        final progress = (appState.vCoins / firstBat.priceCoins).clamp(0.0, 1.0);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildGoalTracker(progress, firstBat, appState)),
            SliverToBoxAdapter(child: _buildCategoryFilter()),
            SliverToBoxAdapter(child: _buildLimitedDropCard()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductCard(_filteredProducts[index], appState),
                  childCount: _filteredProducts.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildDoubleCoinCard()),
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        );
      },
    );
  }

  Widget _buildGoalTracker(double progress, Product targetProduct, AppState appState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.cardSurfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toInt()}% to your ${targetProduct.name}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${appState.vCoins}/${targetProduct.priceCoins} V-Coins',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ProductCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = ProductCategory.values[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonGreen : AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppTheme.neonGreen : AppTheme.border,
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, AppState appState) {
    final isOwned = _ownedProductIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              isOwned: isOwned,
              onRedeem: () {
                setState(() => _ownedProductIds.add(product.id));
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: product.imageURL.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageURL,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: AppTheme.cardSurfaceLight,
                          child: const Center(
                            child: Icon(Icons.sports_cricket, color: AppTheme.textTertiary, size: 32),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.cardSurfaceLight,
                          child: const Center(
                            child: Icon(Icons.sports_cricket, color: AppTheme.textTertiary, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.cardSurfaceLight,
                        child: const Center(
                          child: Icon(Icons.sports_cricket, color: AppTheme.textTertiary, size: 32),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.subtitle.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (isOwned)
                    Text(
                      'OWNED',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  else
                    Text(
                      '${product.priceCoins}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitedDropCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.12),
            AppTheme.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'LIMITED DROP',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Signed Dugout Series',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Exclusive signed bats from pro players. Only 50 available.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.sports_cricket, color: AppTheme.neonGreen, size: 48),
        ],
      ),
    );
  }

  Widget _buildDoubleCoinCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.12),
            AppTheme.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: AppTheme.goldAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Double Coin Weekend',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete drills this weekend for 2x V-Coins!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
