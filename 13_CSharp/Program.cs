using System.Text.RegularExpressions;
using _13_CSharp;

// const string filePath = "input_sample.txt";
const string filePath = "input.txt";


void Main()
{
    var games = ParseFile(filePath);
    var solution = games.Select(game => Solve(game)).Sum();
    Console.WriteLine(solution);

    var offset = new Coord
    {
        X = 10000000000000,
        Y = 10000000000000,
    };
    
    var solutionPart2 = games
        .Select(game => new Game
        {
            buttonA = game.buttonA,
            buttonB = game.buttonB,
            prize = game.prize + offset,
        })
        .Select(game => Solve(game))
        .Sum();
    Console.WriteLine(solutionPart2);
}

long Solve(Game game)
{
    var prize = game.prize.ToDoubleCoord();
    var buttonA = game.buttonA.ToDoubleCoord();
    var buttonB = game.buttonB.ToDoubleCoord();
    
    var top = prize.Y - (buttonB.Y*prize.X)/buttonB.X;
    var bottom = buttonA.Y - (buttonB.Y * buttonA.X) / buttonB.X;
    var a = top / bottom;

    var b = (prize.X - buttonA.X * a) / buttonB.X;

    var aInt = (long) Math.Round(a);
    var bInt = (long) Math.Round(b);
    
    var pos = game.buttonA * aInt + game.buttonB * bInt;
    if (pos == game.prize)
    {
        return aInt*3+bInt;
    }

    return 0;
}

IEnumerable<Game> ParseFile(string path)
{
    var contents = File.ReadAllText(path);
    var parts = contents.Split(Environment.NewLine+Environment.NewLine);
    var reg = new Regex(@"Button A: X\+([0-9]+), Y\+([0-9]+)\nButton B: X\+([0-9]+), Y\+([0-9]+)\nPrize: X=([0-9]+), Y=([0-9]+)");
    var parsedParts = parts.Select(part =>
    {
        var match = reg.Match(part);
        if (!match.Success) throw new FormatException($"Regex didn't match: {part}");
        return new Game
        {
            buttonA = new Coord
            {
                X = int.Parse(match.Groups[1].Value),
                Y = int.Parse(match.Groups[2].Value),
            },
            buttonB = new Coord
            {
                X = int.Parse(match.Groups[3].Value),
                Y = int.Parse(match.Groups[4].Value),
            },
            prize = new Coord
            {
                X = int.Parse(match.Groups[5].Value),
                Y = int.Parse(match.Groups[6].Value),
            }
        };
    });
    return parsedParts;
}

Main();

