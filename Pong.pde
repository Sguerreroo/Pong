import processing.sound.*;

Ball ball;
Player player1, player2;
ScoreBoard scoreBoard;

int showGoal = 0, goalsToWin = 3;

SoundFile borders, player, goal, win;

void setup() {
  size(1200, 800);
  int speedX = chooseRandomDirection() * 5;
  int speedY = chooseRandomDirection() * 5;
  ball = new Ball(width/2, height/2, 30, 30, speedX, speedY, color(255));
  player1 = new Player(20, height/2 - 50, 20, 150, 20, color(255));
  player2 = new Player(width - 40, height/2 - 50, 20, 150, 0, color(255));
  scoreBoard = new ScoreBoard(0, 0);
  borders = new SoundFile(this, "./Sounds/Bass-Drum-1.wav");
  player = new SoundFile(this, "./Sounds/Bass-Drum-2.wav");
  goal = new SoundFile(this, "./Sounds/M-Audio-Venom-8Bit-Tremo-C4.wav");
  win = new SoundFile(this, "./Sounds/M-Audio-Venom-Disintegr8-C3.wav");
}

void draw() {
  background(0);
  drawCenterLine();
  ball.display();
  player1.display();
  player2.display();

  ball.move();
  ball.checkCollision();
  scoreBoard.display();

  if (keyPressed) {
    if (key == 'w' || key == 'W')
      player1.moveUp();
    if (key == 's' || key == 'S')
      player1.moveDown();
  }

  if (showGoal > 0) {
    textSize(100);
    text("GOAL!!", width/2, height - 200);
    showGoal--;
  }
}

void mouseMoved() {
  if (mouseY >= 0 && mouseY <= height - player2.height_)
    player2.yPosition = mouseY;
}

void drawCenterLine() {
  stroke(255);
  strokeWeight(3);
  for (int i = 0; i < height; i += 25)
    line(width/2, i, width/2, i+10);
  noStroke();
}

int chooseRandomDirection() {
  if (random(-1, 1) > 0)
    return 1;
  else
    return -1;
}

void borders() {
  borders.play();
}

void player() {
  player.play();
}

void goal() {
  goal.play();
}

void win() {
  win.play();
}

class ScoreBoard {

  int player1Score, player2Score;

  ScoreBoard(int player1Score, int player2Score) {
    this.player1Score = player1Score;
    this.player2Score = player2Score;
  }

  void addPointPlayer1() {
    this.player1Score++;
  }

  void addPointPlayer2() {
    this.player2Score++;
  }

  void display() {
    textSize(50);
    text(this.player1Score, (width/2) - 100, 75);
    text(this.player2Score, (width/2) + 100, 75);
  }

  void checkEndGame() {
    textSize(125);
    textAlign(CENTER);
    if (this.player1Score == goalsToWin) {
      thread("win");
      text("Player 1 Wins", width/2, height/2);
      noLoop();
    }
    if (this.player2Score == goalsToWin) {
      thread("win");
      text("Player 2 Wins", width/2, height/2);
      noLoop();
    }
  }
}

class Player {

  int xPosition, yPosition, width_, height_;
  float speed;
  color color_;

  Player(int xPosition, int yPosition, int width_, int height_, float speed, 
    color color_)
  {
    this.xPosition = xPosition;
    this.yPosition = yPosition;
    this.width_ = width_;
    this.height_ = height_;
    this.speed = speed;
    this.color_ = color_;
  }

  void display() {
    fill(this.color_);
    rect(this.xPosition, this.yPosition, this.width_, this.height_);
  }

  void moveUp() {
    if (this.yPosition > this.speed)
      this.yPosition -= speed;
    else
      this.yPosition = 0;
  }

  void moveDown() {
    if (this.yPosition + this.height_ + speed < height)
      this.yPosition += speed;
    else
      this.yPosition = height - this.height_;
  }
}

class Ball {

  int xPosition, yPosition, width_, height_;
  final float initialSpeedX, initialSpeedY;
  float speedX, speedY;
  color color_;
  boolean goRight, goDown;

  Ball(int xPosition, int yPosition, int width_, int height_, float speedX, float speedY, 
    color color_)
  {
    this.xPosition = xPosition;
    this.yPosition = yPosition;
    this.width_ = width_;
    this.height_ = height_;
    this.initialSpeedX = speedX;
    this.initialSpeedY = speedY;
    this.speedX = speedX;
    this.speedY = speedY;
    this.color_ = color_;
  }

  void display() {
    fill(this.color_);
    ellipse(this.xPosition, this.yPosition, this.width_, this.height_);
  }

  void move() {
    xPosition += speedX;
    yPosition += speedY;
  }

  void checkCollision() {
    if (speedX < 0)
      playerCollision(player1);
    else
      playerCollision(player2);

    topBottomBorders();
    checkGoal();
  }

  private void playerCollision(Player player) {
    if (player.yPosition <= this.yPosition + height_ / 2 &&
      this.yPosition - height_ / 2 <= player.yPosition + player.height_ &&
      player.xPosition <= this.xPosition + this.width_ / 2 &&
      this.xPosition - this.width_ / 2 <= player.xPosition + player.width_) 
    {       
      speedX *= 1.05;
      speedX = -speedX;
      thread("player");
    }
  }

  private void topBottomBorders() {
    if (this.yPosition - this.height_ / 2 < 0 ||
      this.yPosition + this.height_ / 2 > height)    
    {
      speedY *= 1.05;
      speedY = -speedY;
      thread("borders");
    }
  }

  private void checkGoal() {
    if (this.xPosition - this.width_ / 2 > width) {
      scoreBoard.addPointPlayer1();
      if (scoreBoard.player1Score < goalsToWin)
        thread("goal");
      showGoal = 50;
      resetBall();
    }
    if (this.xPosition < 0 - this.width_) {
      scoreBoard.addPointPlayer2();
      if (scoreBoard.player2Score < goalsToWin)
        thread("goal");
      showGoal = 50;
      resetBall();
    }
    scoreBoard.checkEndGame();
  }

  private void resetBall() {
    this.xPosition = width/2;
    this.yPosition = height/2;
    if (this.speedX < 0)
      this.speedX = this.initialSpeedX;
    else
      this.speedX = -this.initialSpeedX;
    this.speedY = chooseRandomDirection() * initialSpeedY;
  }
}
