import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.warmCream,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.inkDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'SHALBAN SMART could not reach the store. Check your Wi-Fi or mobile data and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.inkMuted,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isRetrying ? null : onRetry,
                  icon: isRetrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppTheme.warmCream,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(isRetrying ? 'Reconnecting...' : 'Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
