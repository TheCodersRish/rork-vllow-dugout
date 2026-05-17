import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isOwned;
  final VoidCallback? onRedeem;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isOwned = false,
    this.onRedeem,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isOwned;

  @override
  void initState() {
    super.initState();
    _isOwned = widget.isOwned;
  }

  void _showRedeemDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Redeem Product',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Spend ${widget.product.priceCoins} V-Coins to redeem ${widget.product.name}?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.gameData.spendCoins(widget.product.priceCoins);
              setState(() => _isOwned = true);
              widget.onRedeem?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.product.name} redeemed!'),
                  backgroundColor: AppTheme.neonGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'REDEEM',
              style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final canAfford = appState.vCoins >= widget.product.priceCoins;

        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          body: CustomScrollView(
            slivers: [
              _buildHeroImage(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(appState, canAfford),
                      const SizedBox(height: 16),
                      _buildRedeemButton(appState, canAfford),
                      const SizedBox(height: 24),
                      _buildPowerRating(),
                      const SizedBox(height: 24),
                      _buildSweetSpotChart(),
                      const SizedBox(height: 24),
                      _buildTechnicalSpecs(),
                      const SizedBox(height: 24),
                      _buildAIInsight(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final heroHeight = screenWidth * (5 / 4);

    return SliverAppBar(
      expandedHeight: heroHeight,
      pinned: true,
      backgroundColor: AppTheme.darkBg,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.product.imageURL.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.product.imageURL,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.cardSurface),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.cardSurface,
                      child: const Icon(Icons.sports_cricket, color: AppTheme.textTertiary, size: 64),
                    ),
                  )
                : Container(
                    color: AppTheme.cardSurface,
                    child: const Icon(Icons.sports_cricket, color: AppTheme.textTertiary, size: 64),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.darkBg],
                ),
              ),
            ),
            if (widget.product.woodType.isNotEmpty)
              Positioned(
                top: 100,
                right: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.white.withOpacity(0.15),
                    child: const Text(
                      'GRADE 1+ WILLOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppState appState, bool canAfford) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE ELITE SANCTUARY',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.product.subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (_isOwned)
          Text(
            'OWNED',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${widget.product.priceCoins}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'V-COINS',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRedeemButton(AppState appState, bool canAfford) {
    if (_isOwned) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.neonGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 22),
            const SizedBox(width: 8),
            Text(
              'OWNED',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: canAfford ? () => _showRedeemDialog(appState) : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: canAfford ? AppTheme.neonGreen : AppTheme.cardSurfaceLight,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          canAfford
              ? 'REDEEM FOR ${widget.product.priceCoins} V-COINS'
              : 'NOT ENOUGH V-COINS',
          style: TextStyle(
            color: canAfford ? Colors.black : AppTheme.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPowerRating() {
    final rating = widget.product.powerRating;
    final ratingColor = rating >= 90
        ? AppTheme.neonGreen
        : rating >= 75
            ? AppTheme.goldAccent
            : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: rating / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.cardSurfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
                  ),
                ),
                Text(
                  '$rating',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POWER RATING',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rating >= 90
                      ? 'Elite Performance'
                      : rating >= 75
                          ? 'High Performance'
                          : 'Solid Performer',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Based on player analytics & materials',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSweetSpotChart() {
    final zones = ['Cover', 'Mid-On', 'Square', 'Fine Leg', 'Straight'];
    final values = [0.85, 0.72, 0.90, 0.65, 0.78];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SWEET SPOT ANALYSIS',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(zones.length, (i) {
                final barHeight = values[i] * 100;
                final barColor = Color.lerp(AppTheme.goldAccent, AppTheme.neonGreen, values[i])!;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(values[i] * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          zones[i],
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    final specs = <Map<String, dynamic>>[
      {'icon': Icons.forest, 'label': 'WOOD TYPE', 'value': widget.product.woodType.isEmpty ? 'N/A' : widget.product.woodType},
      {'icon': Icons.fitness_center, 'label': 'WEIGHT', 'value': widget.product.weight.isEmpty ? 'N/A' : widget.product.weight},
      {'icon': Icons.balance, 'label': 'BALANCE', 'value': widget.product.balance.isEmpty ? 'N/A' : widget.product.balance},
      {'icon': Icons.sports_cricket, 'label': 'HANDLE GRIP', 'value': widget.product.handleGrip.isEmpty ? 'N/A' : widget.product.handleGrip},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TECHNICAL SPECS',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: specs.map((spec) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(spec['icon'] as IconData, color: AppTheme.textTertiary, size: 14),
                    const SizedBox(height: 4),
                    Text(
                      spec['label'] as String,
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spec['value'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.08),
            AppTheme.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.neonGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI-Enhanced Performance',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description.isNotEmpty
                ? widget.product.description
                : 'Our AI analysis suggests this product pairs well with your current training profile. '
                    'Based on your batting style and performance data, expect improved shot timing and control.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
