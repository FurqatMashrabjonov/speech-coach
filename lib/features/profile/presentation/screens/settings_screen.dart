import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/paywall/presentation/providers/subscription_provider.dart';
import 'package:speech_coach/shared/providers/theme_provider.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

final micQualityProvider = StateProvider<String>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getString('mic_quality') ?? 'High';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final sub = ref.watch(subscriptionProvider);
    final micQuality = ref.watch(micQualityProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dark_mode_outlined,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Dark Mode'),
                trailing: Switch.adaptive(
                  value: themeMode == ThemeMode.dark,
                  activeTrackColor: AppColors.success,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Audio',
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mic_outlined,
                      color: AppColors.secondary, size: 20),
                ),
                title: const Text('Microphone Quality'),
                subtitle: Text(micQuality),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: context.textTertiary),
                onTap: () => _showMicQualitySheet(context, ref, micQuality),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Subscription',
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sub.isPro
                        ? Icons.workspace_premium_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                title: Text(sub.isPro ? 'Manage Subscription' : 'Upgrade to Pro'),
                subtitle: Text(sub.isPro ? 'Pro' : 'Free'),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: context.textTertiary),
                onTap: () {
                  if (sub.isPro) {
                    ref.read(subscriptionProvider.notifier).showCustomerCenter();
                  } else {
                    ref.read(subscriptionProvider.notifier).showPaywall();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: AppColors.skyBlue, size: 20),
                ),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: AppColors.gold, size: 20),
                ),
                title: const Text('Privacy Policy'),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: context.textTertiary),
                onTap: () => launchUrl(
                  Uri.parse('https://speechyai.app/privacy'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.gavel_outlined,
                      color: AppColors.primaryDark, size: 20),
                ),
                title: const Text('Terms of Service'),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: context.textTertiary),
                onTap: () => launchUrl(
                  Uri.parse('https://speechyai.app/terms'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMicQualitySheet(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Microphone Quality', style: AppTypography.titleMedium()),
              const SizedBox(height: 8),
              for (final quality in ['Low', 'Medium', 'High'])
                ListTile(
                  title: Text(quality),
                  trailing: current == quality
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () async {
                    ref.read(micQualityProvider.notifier).state = quality;
                    final prefs = ref.read(sharedPreferencesProvider);
                    await prefs.setString('mic_quality', quality);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
