using Gee;

const string filePath = "input.txt";
//const string filePath = "input_sample.txt";
int mapX = 101;
//int64 mapX = 11;
int mapY = 103;
//int64 mapY = 7;


int main(string[] args) {
    var robots = read_file(filePath);

    var topLeft = 0;
    var topRight = 0;
    var bottomLeft = 0;
    var bottomRight = 0;

    foreach (var robot in robots) {
        var pos = robot.advance(100, mapX, mapY);

        var top = pos.y < (mapY / 2);
        var bottom = pos.y > (mapY / 2);
        var left = pos.x < (mapX / 2);
        var right = pos.x > (mapX / 2);

        if (top && left) {
            topLeft++;
        }
        if (top && right) {
            topRight++;
        }
        if (bottom && left) {
            bottomLeft++;
        }
        if (bottom && right) {
            bottomRight++;
        }
    }

    stdout.printf("topLeft=%d, topRight=%d, bottomLeft=%d, bottomRight=%d\n", topLeft, topRight, bottomLeft, bottomRight);
    stdout.printf("%d\n", topLeft*topRight*bottomLeft*bottomRight);

    return 0;
}

Coord to_coord(string input) {
    var parts = input.split("=");
    var coord = parts[1].split(",");
    var x = int64.parse(coord[0]);
    var y = int64.parse(coord[1]);
    return new Coord(x, y);
}

public class Coord : GLib.Object {
    public int64 x;
    public int64 y;

    public Coord(int64 x, int64 y) {
        this.x = x;
        this.y = y;
    }
}

public class Robot : GLib.Object {
    public Coord startPos;
    public Coord velocity;

    public Robot(Coord startPos, Coord velocity) {
        this.startPos = startPos;
        this.velocity = velocity;
    }

    public Coord advance(int64 seconds, int64 mapX, int64 mapY) {
        var xNext = (this.startPos.x + (this.velocity.x * seconds)) % mapX;
        if (xNext < 0) {
            xNext = mapX + xNext;
        }
        var yNext = (this.startPos.y + (this.velocity.y * seconds)) % mapY;
        if (yNext < 0) {
            yNext = mapY + yNext;
        }
        return new Coord(xNext, yNext);
    }
}

ArrayList<Robot> read_file(string inputFile) {
    var file = File.new_for_path(filePath);
    if (!file.query_exists ()) {
        error("File '%s' doesn't exist.\n", file.get_path ());
        return new ArrayList<Robot>();
    }

    var dis = new DataInputStream(file.read ());

    string line;
    var robots = new ArrayList<Robot>();
    while ((line = dis.read_line (null)) != null) {
        var parts = line.split(" ");
        var point = to_coord(parts[0]);
        var velocity = to_coord(parts[1]);
        var robot = new Robot(point, velocity);
        robots.add(robot);
    }
    return robots;
}

