import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../models/game_config.dart';
import '../constants/colors.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.boardBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 标题
            const Icon(
              Icons.flight,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '飞行棋',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '经典桌面游戏',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 60),

            // 游戏模式选择
            _buildModeButton(
              context,
              '双人对战',
              Icons.people,
              GameMode.pvp,
              2,
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              '三人对战',
              Icons.groups,
              GameMode.pvp,
              3,
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              '四人对战',
              Icons.groups_3,
              GameMode.pvp,
              4,
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              '人机对战 (2人)',
              Icons.computer,
              GameMode.pvai,
              2,
            ),
            const SizedBox(height: 16),
            _buildModeButton(
              context,
              '人机对战 (4人)',
              Icons.computer,
              GameMode.pvai,
              4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    IconData icon,
    GameMode mode,
    int playerCount,
  ) {
    return SizedBox(
      width: 280,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          final gameState = context.read<GameStateProvider>();
          gameState.startGame(mode, playerCount);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        },
        icon: Icon(icon, size: 28),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
