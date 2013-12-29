import std.stdio;
import std.math;
import std.string;

void main() {
    auto a = Body(50_000, Vector2(-5, 0), Vector2(0, 0));
    auto b = Body(50_000, Vector2(5, 0), Vector2(0, 0));
    writeln(gravity(a, b));
    //evolve([a, b]);
}

struct Body {
    double mass;
    Vector2 r;
    Vector2 v;
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
}


Vector2 vectorBetween(const Body b1, const Body b2) pure {
    return Vector2( b2.r.x - b1.r.x, b2.r.y - b1.r.y );
}

enum G = 6.67 * 10.0^^-11;
Vector2 gravity(const Body b1, const Body b2) pure {
    auto force = G * b1.mass * b2.mass / distance(b1, b2);
    debug { writeln("  force: ", force); }

    auto v = vectorBetween(b1, b2);
    debug { writeln("  initial v: ", v); }

    v.normalize();
    debug { writeln("  v: ", v); }

    v.scale(force);
    debug { writeln("  v: ", v); }
    return v;
}

double distance(const Body b1, const Body b2) pure {
    return sqrt( (b1.r.x - b2.r.x)^^2 + (b1.r.y - b2.r.y)^^2 );
}

void evolve(Body[] bodies) {
    Vector2[] forces = new Vector2[bodies.length];
    foreach(ref f; forces) {
        f = Vector2(0.0, 0.0);
    }

    Vector2 tmp;
    foreach(i; 0 .. bodies.length) {
        foreach(j; (i+1) .. bodies.length) {
            writeln("i = ", i, ", j = ", j);
            tmp = gravity(bodies[i], bodies[j]);
            forces[i].add( tmp );
            tmp.scale(-1);
            forces[j].add( tmp );
        }
    }

    writeln(forces);

}
