package industries.disappointment;

public class Position {
    public int x, y;
    public Position(int x, int y) {
        this.x = x;
        this.y = y;
    }
    public Position move(Direction direction) {
        return switch (direction) {
            case UP -> new Position(x, y-1);
            case DOWN -> new Position(x, y+1);
            case LEFT -> new Position(x-1, y);
            case RIGHT -> new Position(x+1, y);
        };
    }
}