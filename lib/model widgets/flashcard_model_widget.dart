import 'package:flutter/material.dart';

class FlashCardModelWidget extends StatefulWidget {
  final String title;
  final String backContent;

  const FlashCardModelWidget(
      {super.key, required this.title, required this.backContent});

  @override
  _FlashCardModelWidgetState createState() => _FlashCardModelWidgetState();
}

class _FlashCardModelWidgetState extends State<FlashCardModelWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.isCompleted) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        });
      },
      child: Column(
        children: [
          // Only animated front and back card area (no button inside)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.rotationY(_animation.value * 3.14159),
                alignment: Alignment.center,
                child: _buildCard(),
              );
            },
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 310,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          width: 4,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Front Side (Question)
          _buildFront(),
          // Back Side (Answer)
          _buildBack(),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Visibility(
      visible:
          _animation.value < 0.5, // Show front when animation is less than 0.5
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                print("Edit button pressed");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Visibility(
      visible: _animation.value >= 0.5,
      child: Transform(
        transform: Matrix4.rotationY(_animation.value < 0.5 ? 0 : 3.14159),
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.backContent,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Handle edit action for front side
                  print("Edit button pressed");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
