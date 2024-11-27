import 'package:flutter/material.dart';

class FlashCardModel extends StatefulWidget {
  final String question;
  final String answer;
  final String? questionId; // Optional: For future updates/deletions

  const FlashCardModel({
    super.key,
    required this.question,
    required this.answer,
    this.questionId,
  });

  @override
  _FlashCardModelState createState() => _FlashCardModelState();
}

class _FlashCardModelState extends State<FlashCardModel>
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
          _buildFront(),
          _buildBack(),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return Visibility(
      visible: _animation.value < 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.question,
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
                widget.answer,
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
                  print("Edit button pressed");
                  //get the id for future so this edit button can update the question and answer
                  //im gonna do this later
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
