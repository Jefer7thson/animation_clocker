import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const ClockLoader(),
    );
  }
}

class ClockLoader extends StatefulWidget {
  const ClockLoader({Key? key}) : super(key: key);

  @override
  State<ClockLoader> createState() => _ClockLoaderState();
}

class _ClockLoaderState extends State<ClockLoader>
    with TickerProviderStateMixin {
  static const tickLength = 12;
  static const squareSize = 12.0;
  late Animation tickAnimation;
  late AnimationController animationController;

  late List<Color> colors; // Lista de cores

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )
      ..forward()
      ..repeat();
    tickAnimation = Tween<double>(
      begin: 0,
      end: 4 * math.pi,
    ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    animationController.addListener(() {
      if (animationController.isAnimating) {
        setState(() {});
      }
    });

    // Inicialize a lista de cores com a cor branca
    colors = List.generate(tickLength, (index) => Colors.white);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _changeSquareColor() {
    setState(() {
      // Gerar cor aleatória
      final randomColor = Color.fromARGB(
        255,
        math.Random().nextInt(256), // Vermelho
        math.Random().nextInt(256), // Verde
        math.Random().nextInt(256), // Azul
      );

      // Atribuir nova cor aleatória a todos os quadrados
      colors = List.filled(tickLength, randomColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    const offsetAngle = (2 * math.pi) / tickLength;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/animed.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              ...colors.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final color = entry.value;
                final finalAngle = offsetAngle * (tickLength - 1 - index);
                final rotate = tickAnimation.value <= 2 * math.pi
                    ? math.min<double>(finalAngle, tickAnimation.value)
                    : tickAnimation.value > 2 * math.pi
                        ? finalAngle
                        : tickAnimation.value;
                final yDefaultPosition = -index * squareSize;
                final translateY = rotate == finalAngle
                    ? -tickLength * squareSize
                    : tickAnimation.value > 2 * math.pi
                        ? (index - tickLength) * squareSize
                        : yDefaultPosition;

                return TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: yDefaultPosition,
                    end: translateY,
                  ),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, translateYAnimValue, _) {
                    return Transform.rotate(
                      angle: rotate,
                      child: Transform.translate(
                        offset: Offset(0.0, translateYAnimValue),
                        child: Container(
                          height: squareSize,
                          width: squareSize,
                          color: color,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeSquareColor,
        tooltip: 'Change Color',
        child: Icon(Icons.color_lens),
      ),
    );
  }
}
