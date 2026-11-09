
import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _glowController;
  late final AnimationController _loadingController;

  late final Animation<double> _imageScale;
  late final Animation<double> _imageFade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );

    _imageScale = Tween<double>(
      begin: 1.04,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _imageFade = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeIn,
    );

    _introController.forward();
    _glowController.repeat(reverse: true);
    _loadingController.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 5200),
      _goToHome,
    );
  }

  void _goToHome() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _glowController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _introController,
            _glowController,
            _loadingController,
          ]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _imageFade,
              child: Transform.scale(
                scale: _imageScale.value,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Original JAL Studio splash image
                    Image.asset(
                      'assets/images/Splash.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              'JAL STUDIO',
                              style: TextStyle(
                                color: Color(0xFFD6B36A),
                                fontSize: 30,
                                letterSpacing: 8,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Subtle cinematic lighting; no extra border
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(
                              0,
                              -0.15 + (_glowController.value * 0.08),
                            ),
                            radius: 1.1,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.08),
                              Colors.black.withOpacity(0.30),
                            ],
                            stops: const [0.35, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Animated gold linear loader
                    Positioned(
                      left: 50,
                      right: 50,
                      bottom:
                          MediaQuery.of(context).padding.bottom + 35,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _loadingController.value,
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD6B36A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
