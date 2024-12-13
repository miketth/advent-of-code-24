namespace _13_CSharp;

public class Coord
{
    public long X { get; set; }
    public long Y { get; set; }
    
    public static Coord operator +(Coord a, Coord b) => new Coord { X = a.X + b.X, Y = a.Y + b.Y };
    public static Coord operator *(Coord a, int b) => new Coord { X = a.X * b, Y = a.Y * b };
    public static Coord operator *(Coord a, long b) => new Coord { X = a.X * b, Y = a.Y * b };
    public static bool operator ==(Coord a, Coord b) => a.Equals(b);
    public static bool operator !=(Coord a, Coord b) => !a.Equals(b);
    public override bool Equals(object? obj) => obj is Coord coord && X == coord.X && Y == coord.Y;
    public override int GetHashCode() => HashCode.Combine(X, Y);
    
    public DoubleCoord ToDoubleCoord() => new DoubleCoord { X = X, Y = Y };
}


