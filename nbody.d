import std.stdio;
import std.math;
import std.string;
import std.conv : to;
import std.array : split;

void main(string[] args) {
    double dt = to!double(args[1]);
    int numsteps = to!int(args[2]);

    string inp;
    readf("%s", &inp);
    auto bods = parseInput(inp); 

    /*
    auto a = Body(25_850_000_000_000, Vector2(-5, 0), Vector2(-1, 0));
    auto b = Body(20_450_000_000_000, Vector2(5, 0), Vector2(1, 0));
    auto bods = [a, b];
    */
    foreach(bod; bods) { writeln(bod); }
    writeln("---");

    foreach(i; 0 .. numsteps) {
        evolve(bods, dt);

        foreach(bod; bods) { writeln(bod); }
        writeln("---");
    }
}

double[] parseLine(string line) {
    double[] x;
    foreach(num; split(line)) {
        x ~= to!double(num);
    }
    return x;
}

unittest {
   string aline = " 1.4960e+11  0.0000e+00  0.0000e+00  2.9800e+04  5.9740e+24";
   writeln(parseLine(aline));
 
}

Body[] parseInput(string inp) {
    auto lines = splitLines(inp);
    auto len = to!int(lines[0]);


    Body[] bods = new Body[len];
    foreach(i, ref bod; bods) {
        auto x = parseLine(lines[i+1]);
        bod = Body(x[4], 
                   Vector2(x[0], x[1]), 
                   Vector2(x[2], x[3]));
    }

    return bods;

}

struct Body {
    double mass;
    Vector2 r;
    Vector2 v;

    string toString() {
        return format("%f %s %s", mass, r.toString(), v.toString());
    }
}

struct Vector2 {
    double x, y;

    double mag() pure {
        return sqrt(x^^2 + y^^2);
    }

    void normalize() pure {
        auto m = mag();
        this.x /= m;
        this.y /= m;
    }

    void scale(double c) pure {
        this.x *= c;
        this.y *= c;
    }

    string toString() {
        return format("(%f, %f)", this.x, this.y);
    }

    void add(Vector2 v) pure {
        this.x += v.x;
        this.y += v.y;
    }

    Vector2 times(double c) pure {
        return Vector2(this.x * c, this.y * c);
    }
}


Vector2 vectorBetween(const Body b1, const Body b2) pure {
    return Vector2( b2.r.x - b1.r.x, b2.r.y - b1.r.y );
}

enum G = 6.67 * 10.0^^-11;
Vector2 gravity(const Body b1, const Body b2) pure {
    auto force = G * b1.mass * b2.mass / distance(b1, b2);

    auto v = vectorBetween(b1, b2);
    v.normalize();
    v.scale(force);
    return v;
}

double distance(const Body b1, const Body b2) pure {
    return sqrt( (b1.r.x - b2.r.x)^^2 + (b1.r.y - b2.r.y)^^2 );
}

void evolve(ref Body[] bodies, double dt) {
    Vector2[] forces = new Vector2[bodies.length];
    foreach(ref f; forces) {
        f = Vector2(0.0, 0.0);
    }

    debug { writeln("inside evolve"); }

    Vector2 force;
    foreach(i; 0 .. bodies.length) {
        foreach(j; (i+1) .. bodies.length) {
            debug { writeln("i = ", i, ", j = ", j); }
            force = gravity(bodies[i], bodies[j]);
            forces[i].add( force );
            forces[j].add( force.times(-1) );
        }
    }

    debug {
        foreach(f; forces) {
            writeln("  force after: ", f);
        }
    }

    // leapfrog
    foreach(i, ref bod; bodies) {
        auto a = forces[i];
        a.scale(1 / bod.mass); // divide force by mass to get acceleration

        debug { writeln("  accel: ", a); }
        debug { writeln("  delta v: ", a.times(dt)); }

        bod.v.add( a.times(dt) );

        debug { writeln("  new v: ", bod.v); }
        bod.r.add( bod.v.times(dt) );
    }
}
