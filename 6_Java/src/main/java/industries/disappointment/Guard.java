package industries.disappointment;

public class Guard {
    public Position position;
    public Direction direction;
    public Guard(Position position, Direction direction) {
        this.position = position;
        this.direction = direction;
    }

    public Position nextPosition() {
        return position.move(direction);
    }

    public Guard(Guard guard) {
        this.position = new Position(guard.position.x, guard.position.y);
        this.direction = guard.direction;
    }
}
