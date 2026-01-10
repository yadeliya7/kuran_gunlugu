import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';
import '../core/constants/strings.dart';

class ActionButtons extends StatelessWidget {
  final bool isFavorited;
  final bool isPlaying;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;
  final VoidCallback onTogglePlay;

  const ActionButtons({
    super.key,
    required this.isFavorited,
    required this.isPlaying,
    required this.onToggleFavorite,
    required this.onShare,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SAVE BUTTON
          SizedBox(
            width: 70,
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorited ? AppColors.gold : Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t('save').toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: isFavorited ? AppColors.gold : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SHARE BUTTON
          Container(
            height: 65,
            width: 65,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              alignment: Alignment.center,
              icon: const Icon(
                Icons.share,
                color: AppColors.background,
                size: 26,
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                onShare();
              },
            ),
          ),

          // LISTEN BUTTON
          SizedBox(
            width: 70,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTogglePlay();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow_outlined,
                    color: isPlaying ? AppColors.gold : Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (isPlaying ? t('stop') : t('listen')).toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: isPlaying ? AppColors.gold : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
