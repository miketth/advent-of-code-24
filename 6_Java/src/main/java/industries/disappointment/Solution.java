package industries.disappointment;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Solution {
//    String filePath = "input_sample.txt";
    String filePath = "input.txt";

    public void solve() throws IOException {
        var text = Files.readString(Path.of(filePath), Charset.defaultCharset());
        var data = Arrays.stream(text.strip().split("\n")).map(line -> line.trim().split("")).toArray(String[][]::new);

        Position guardPos = null;
        Direction guardDirection = null;
        var map = new ArrayList<List<Field>>();
        for (int y = 0; y < data.length; y++) {
            var row = data[y];
            var mapRow = new ArrayList<Field>();
            for (int x = 0; x < row.length; x++) {
                var item = row[x];

                var direction = guardDirection(item);
                if (direction != null) {
                    guardPos = new Position(x, y);
                    guardDirection = direction;
                }

                if (item.equals("#")) {
                    mapRow.add(new Field.Obstruction());
                } else {
                    mapRow.add(new Field.Empty(direction));
                }
            }
            map.add(mapRow);
        }

        var guard = new Guard(guardPos, guardDirection);

        if (guardPos == null) {
            throw new AssertionError("No guard found");
        }

        walkGuard(guard, map);

        var fieldsTouched = 0;
        for (List<Field> row : map) {
            for (Field field : row) {
                if (!field.previousGuardDirections().isEmpty()) {
                    fieldsTouched++;
                }
            }
        }
        System.out.println(fieldsTouched);
    }

    private void walkGuard(Guard guard, List<List<Field>> map) {
        var maxPos = new Position(map.getFirst().size() - 1, map.size() - 1);
        var mapArea = new Area(new Position(0, 0), maxPos);

        while (true) {
            var nextPosition = guard.nextPosition();
            if (!mapArea.contains(nextPosition)) {
                break;
            }

            var field = map.get(nextPosition.y).get(nextPosition.x);
            field.meetGuard(guard);
        }
    }

    private Direction guardDirection(String item) {
        return switch (item) {
            case "^" -> Direction.UP;
            case ">" -> Direction.RIGHT;
            case "<" -> Direction.LEFT;
            case "v" -> Direction.DOWN;
            default -> null;
        };
    }

    private static class Area {
        public Position topLeft, bottomRight;
        public Area(Position topLeft, Position bottomRight) {
            this.topLeft = topLeft;
            this.bottomRight = bottomRight;
        }

        public boolean contains(Position position) {
            return
                    position.x >= this.topLeft.x &&
                    position.x <= this.bottomRight.x &&
                    position.y >= this.topLeft.y &&
                    position.y <= this.bottomRight.y;
        }
    }
}
