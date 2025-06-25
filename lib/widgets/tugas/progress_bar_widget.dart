import 'package:flutter/material.dart';
import 'package:tugasku/constants.dart';

class ProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final bool showPercentage;
  final bool animated;
  
  const ProgressBar({
    super.key, 
    required this.progress,
    this.height = 8,
    this.showPercentage = false,
    this.animated = true,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      if (widget.animated) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return greenColor;
    } else if (progress >= 0.5) {
      return orangeColor;
    } else if (progress >= 0.25) {
      return Colors.red.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final progressColor = _getProgressColor(clampedProgress);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background track
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              ),
              
              // Progress fill
              AnimatedBuilder(
                animation: widget.animated ? _progressAnimation : AlwaysStoppedAnimation(clampedProgress),
                builder: (context, child) {
                  final animatedProgress = widget.animated 
                      ? _progressAnimation.value 
                      : clampedProgress;
                      
                  return FractionallySizedBox(
                    widthFactor: animatedProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor,
                            progressColor.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: animatedProgress > 0 ? [
                          BoxShadow(
                            color: progressColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: animatedProgress > 0.1 ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ) : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Percentage text (optional)
        if (widget.showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(clampedProgress * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: progressColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Alternative minimal version for tight spaces
class MiniProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;
  
  const MiniProgressBar({
    super.key,
    required this.progress,
    this.width = 60,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    Color progressColor;
    if (clampedProgress >= 0.8) {
      progressColor = greenColor;
    } else if (clampedProgress >= 0.5) {
      progressColor = orangeColor;
    } else {
      progressColor = Colors.red.shade400;
    }
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedProgress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}