import 'package:flutter/material.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';

class FlashCardModel extends StatefulWidget {
  final String question;
  final String answer;
  final String questionId;
  final String folderId;
  final Color color;

  const FlashCardModel({
    super.key,
    required this.question,
    required this.answer,
    required this.questionId,
    required this.folderId,
    required this.color,
  });

  @override
  _FlashCardModelState createState() => _FlashCardModelState();
}

class _FlashCardModelState extends State<FlashCardModel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _wiggleController;

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
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _wiggleController.dispose();
    super.dispose();
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
        ],
      ),
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _wiggleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset.zero,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                width: 4,
                color: Colors.white,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
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
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return Visibility(
      visible: _animation.value < 0.5,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Center(
          child: Text(
            widget.question,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: getColorForTextAndIcon(widget.color),
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  color: getShade(widget.color, 500),
                  blurRadius: 0,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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
          child: Text(
            widget.answer,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: getColorForTextAndIcon(widget.color),
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  color: getShade(widget.color, 500),
                  blurRadius: 0,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
