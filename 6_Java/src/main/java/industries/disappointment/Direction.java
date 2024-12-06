package industries.disappointment;

public enum Direction {
    UP, DOWN, LEFT, RIGHT;

    public Direction next() {
        return switch (this) {
            case UP -> Direction.RIGHT;
            case RIGHT -> Direction.DOWN;
            case DOWN -> Direction.LEFT;
            case LEFT -> Direction.UP;
        };
    }
}
