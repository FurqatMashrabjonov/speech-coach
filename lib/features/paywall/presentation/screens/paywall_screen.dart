import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Tappable(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.white,
                        size: 40,
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 20),

                    Text(
                      'Upgrade to Pro',
                      style: AppTypography.displaySmall(),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock unlimited practice sessions and take your speaking skills to the next level',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                    const SizedBox(height: 32),

                    // Feature comparison
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _FeatureRow(
                            feature: 'Daily conversations',
                            free: '3 per day',
                            pro: 'Unlimited',
                          ),
                          const Divider(height: 24),
                          _FeatureRow(
                            feature: 'Session length',
                            free: '3 min',
                            pro: '5 min',
                          ),
                          const Divider(height: 24),
                          _FeatureRow(
                            feature: 'Score cards',
                            free: 'Basic',
                            pro: 'Detailed',
                          ),
                          const Divider(height: 24),
                          _FeatureRow(
                            feature: 'All categories',
                            free: '',
                            pro: '',
                            freeIcon: Icons.check_rounded,
                            proIcon: Icons.check_rounded,
                          ),
                          const Divider(height: 24),
                          _FeatureRow(
                            feature: 'Progress analytics',
                            free: '',
                            pro: '',
                            freeIcon: Icons.close_rounded,
                            proIcon: Icons.check_rounded,
                            freeIconColor: context.textTertiary,
                          ),
                          const Divider(height: 24),
                          _FeatureRow(
                            feature: 'Priority support',
                            free: '',
                            pro: '',
                            freeIcon: Icons.close_rounded,
                            proIcon: Icons.check_rounded,
                            freeIconColor: context.textTertiary,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Pricing cards
                    Row(
                      children: [
                        Expanded(
                          child: _PricingCard(
                            title: 'Monthly',
                            price: '\$9.99',
                            period: '/month',
                            isPopular: false,
                            onTap: () {
                              // TODO: RevenueCat integration
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Coming soon!'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PricingCard(
                            title: 'Yearly',
                            price: '\$59.99',
                            period: '/year',
                            savings: 'Save 50%',
                            isPopular: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Coming soon!'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Lifetime deal
                    Tappable(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon!'),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Launch Deal - Lifetime',
                              style: AppTypography.titleMedium(
                                  color: AppColors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$49.99 one-time',
                              style: AppTypography.displaySmall(
                                  color: AppColors.white),
                            ),
                            Text(
                              'Limited time offer',
                              style: AppTypography.labelSmall(
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 32),

                    // Social proof
                    Text(
                      'Join 10,000+ speakers improving daily',
                      style: AppTypography.bodySmall(
                        color: context.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final String free;
  final String pro;
  final IconData? freeIcon;
  final IconData? proIcon;
  final Color? freeIconColor;

  const _FeatureRow({
    required this.feature,
    required this.free,
    required this.pro,
    this.freeIcon,
    this.proIcon,
    this.freeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            feature,
            style: AppTypography.bodySmall(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: freeIcon != null
                ? Icon(
                    freeIcon,
                    size: 18,
                    color: freeIconColor ?? AppColors.success,
                  )
                : Text(
                    free,
                    style: AppTypography.labelSmall(
                      color: context.textSecondary,
                    ),
                  ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: proIcon != null
                ? Icon(proIcon, size: 18, color: AppColors.success)
                : Text(
                    pro,
                    style: AppTypography.labelSmall(color: AppColors.primary),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isPopular;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular
              ? AppColors.primary.withValues(alpha: 0.14)
              : context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? AppColors.primary : context.divider,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Most Popular',
                  style: AppTypography.labelSmall(color: AppColors.white),
                ),
              ),
            Text(title, style: AppTypography.labelMedium()),
            const SizedBox(height: 4),
            Text(price, style: AppTypography.headlineLarge()),
            Text(
              period,
              style: AppTypography.labelSmall(
                color: context.textSecondary,
              ),
            ),
            if (savings != null) ...[
              const SizedBox(height: 4),
              Text(
                savings!,
                style: AppTypography.labelSmall(color: AppColors.success),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
