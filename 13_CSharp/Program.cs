using System.Text.RegularExpressions;
using _13_CSharp;

// const string filePath = "input_sample.txt";
const string filePath = "input.txt";


void Main()
{
    var games = ParseFile(filePath);
    var solution = games.Select(game => Solve(game)).Sum();
    Console.WriteLine(solution);
}

int Solve(Game game)
{
    var solutions = new List<int>();
    for (int a = 0; a < 100; a++)
    {
        for (int b = 0; b < 100; b++)
        {
            var endPos = game.buttonA * a + game.buttonB * b;
            if (endPos == game.prize)
            {
                solutions.Add(a*3 + b);
            }
        }
    }

    if (solutions.Count == 0)
    {
        return 0;
    }
    
    return solutions.Min();
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

