package industries.disappointment;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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

        var walkedMap = walkGuard(guard, map);

        var fieldsTouched = 0;
        for (List<Field> row : walkedMap) {
            for (Field field : row) {
                if (!field.previousGuardDirections().isEmpty()) {
                    fieldsTouched++;
                }
            }
        }
        System.out.println(fieldsTouched);

        var loops = 0;
        for (int y = 0; y < map.size(); y++) {
            var row = map.get(y);
            for (int x = 0; x < row.size(); x++) {
                var field = row.get(x);
                if (field instanceof Field.Empty) {
                    map.get(y).set(x, new Field.Obstruction());
                    try {
                        walkGuard(guard, map);
                    } catch (AssertionError e) {
                        loops++;
                    }
                    map.get(y).set(x, field);
                }
            }
        }
        System.out.println(loops);
    }

    private List<List<Field>> walkGuard(Guard guard, List<List<Field>> map) {
        guard = new Guard(guard);

        map = map.stream().map(row -> {
            return row.stream().map(Field::clone).collect(Collectors.toList());
        }).collect(Collectors.toList());

        var maxPos = new Position(map.getFirst().size() - 1, map.size() - 1);
        var mapArea = new Area(new Position(0, 0), maxPos);

        while (true) {
            var nextPosition = guard.nextPosition();
            if (!mapArea.contains(nextPosition)) {
                break;
            }

            var field = map.get(nextPosition.y).get(nextPosition.x);

            if (field.previousGuardDirections().contains(guard.direction)) {
                throw new AssertionError("Loop detected");
            }

            field.meetGuard(guard);
        }

        return map;
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
