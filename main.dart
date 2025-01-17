import 'dart:math';
import 'package:flutter/material.dart';

class MazeGenerator {
  final int width;
  final int height;
  final int innerWidth;
  final int innerHeight;
  final int randomWallOpenings;

  MazeGenerator({
    required this.width,
    required this.height,
    this.innerWidth = 0,
    this.innerHeight = 0,
    this.randomWallOpenings = 0,
  });

  List<List<int>> generateMaze() {
    List<List<int>> maze =
        List.generate(height, (_) => List.generate(width, (_) => 1));

    void carve(int x, int y) {
      final directions = [
        [0, 1],
        [1, 0],
        [0, -1],
        [-1, 0]
      ]..shuffle();

      for (final dir in directions) {
        final nx = x + dir[0] * 2;
        final ny = y + dir[1] * 2;

        if (nx > 0 &&
            ny > 0 &&
            nx < width - 1 &&
            ny < height - 1 &&
            maze[ny][nx] == 1) {
          maze[y + dir[1]][x + dir[0]] = 0;
          maze[ny][nx] = 0;
          carve(nx, ny);
        }
      }
    }

    maze[1][1] = 0;
    carve(1, 1);

    if (innerWidth > 0 && innerHeight > 0) {
      final startX = (width - innerWidth) ~/ 2;
      final startY = (height - innerHeight) ~/ 2;

      for (int i = 0; i < innerHeight; i++) {
        for (int j = 0; j < innerWidth; j++) {
          maze[startY + i][startX + j] = 0;
        }
      }
    }

    for (int i = 0; i < randomWallOpenings; i++) {
      final x = Random().nextInt(width - 2) + 1;
      final y = Random().nextInt(height - 2) + 1;
      maze[y][x] = 0;
    }

    return maze;
  }
}

class MazeGame extends StatefulWidget {
  final int width;
  final int height;

  MazeGame({required this.width, required this.height});

  @override
  _MazeGameState createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  late List<List<int>> maze;
  late int playerRow;
  late int playerCol;
  late int goalRow;
  late int goalCol;

  @override
  void initState() {
    super.initState();

    // Generate the maze
    MazeGenerator generator = MazeGenerator(
      width: widget.width,
      height: widget.height,
      randomWallOpenings: 5,
    );

    maze = generator.generateMaze();

    // Set initial player position
    playerRow = 1;
    playerCol = 1;

    // Set goal position
    goalRow = widget.height - 2;
    goalCol = widget.width - 2;
    maze[goalRow][goalCol] = 0; // Ensure goal cell is empty
  }

  void movePlayer(int dRow, int dCol) {
    int newRow = playerRow + dRow;
    int newCol = playerCol + dCol;

    if (maze[newRow][newCol] == 0) {
      setState(() {
        playerRow = newRow;
        playerCol = newCol;

        if (playerRow == goalRow && playerCol == goalCol) {
          // Player reached the goal
          _showWinDialog();
        }
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("You Win!"),
        content: Text("Congratulations! You reached the goal."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      playerRow = 1;
      playerCol = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Maze Game")),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.width,
                ),
                itemCount: widget.width * widget.height,
                itemBuilder: (context, index) {
                  int row = index ~/ widget.width;
                  int col = index % widget.width;

                  if (row == playerRow && col == playerCol) {
                    return Container(
                      margin: EdgeInsets.all(1),
                      color: Colors.blue, // Player color
                    );
                  } else if (row == goalRow && col == goalCol) {
                    return Container(
                      margin: EdgeInsets.all(1),
                      color: Colors.green, // Goal color
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.all(1),
                      color: maze[row][col] == 1 ? Colors.black : Colors.white,
                    );
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => movePlayer(0, -1), // Left
                  child: Icon(Icons.arrow_left),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => movePlayer(-1, 0), // Up
                      child: Icon(Icons.arrow_upward),
                    ),
                    ElevatedButton(
                      onPressed: () => movePlayer(1, 0), // Down
                      child: Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => movePlayer(0, 1), // Right
                  child: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MazeGame(width: 15, height: 15));
}
