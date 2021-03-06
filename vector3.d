/**
 *  Implementation of the Vector3 class from Game Physiscs Engine Development
 */

module vector3;

import std.stdio, std.math, std.conv, std.traits;

struct Vector3
{
    /// vector data: x = 0, y = 1, z = 2... as one would hopefully expect...
    float[3] v = [0, 0, 0];

    this (float[3] v_in)
    {
        v[] = v_in;
    }

    this (float x, float y, float z)
    {
        v[0] = x;
        v[1] = y;
        v[2] = z;
    }

    /**
     * METHODS
     */
    void invert()
    {
        v[] *= -1;
    }

    /// magnitude: Pythagoras theorm for 3D
    @property float magnitude()
    {
        return std.math.sqrt(squareMagnitude);
    }

    float squareMagnitude()
    {
        float m2 = 0;
        foreach(i; v) {
            m2 += i*i;
        }
        return m2;
    }

    void normalize()
    {
        float n = magnitude();
        if (n > 0) {
            v[] *= 1/n;
        }
    }

    /**
     * add scaled vector
     * Params:
     *  b     = Vector3 to be scaled and added
     *  scale = scale factor for b
     */
    void addScaledVector(Vector3 b, float scale)
    {
        v[] += (b * scale).v[];
    }

    void clear()
    {
        v = [0, 0, 0];
    }

    /**
     * component product
     * Params:
     *  b = Vector3 to operate on
     * Returns:
     *  Vector3 who's components are multiple of this vector and b's
     */
    Vector3 componentProduct(Vector3 b)
    {
        float[3] tmp = v[].dup;
        tmp[] *= b.v[];
        return Vector3(tmp);
    }

    void componentProductUpdate(Vector3 b)
    {
        v[] *= b.v[];
    }

    Vector3 crossProduct(Vector3 b)
    {
        return Vector3((v[1] * b.v[2]) - (v[2] * b.v[1]),
                       (v[2] * b.v[0]) - (v[0] * b.v[2]),
                       (v[0] * b.v[1]) - (v[1] * b.v[0]));
    }

    /**
     * OPERATORS
     */
    Vector3 opBinary(string op)(Vector3 rhs) if (op != "*")
    {
        float[3] tmp = v[].dup;
        static if (op == "%") {
            return Vector3((v[1] * rhs.v[2]) - (v[2] * rhs.v[1]),
                           (v[2] * rhs.v[0]) - (v[0] * rhs.v[2]),
                           (v[0] * rhs.v[1]) - (v[1] * rhs.v[0]));
        }
        else {
            mixin("tmp[] " ~ op ~ "= rhs.v[];");
            return Vector3(tmp);
        }
    }

    /// scalar multiplication
    Vector3 opBinary(string op)(float rhs) if (op == "*")
    {
        float[3] tmp = v[].dup;
        tmp[] *= rhs;
        return (Vector3(tmp));
    }

    /// dot product
    float opBinary(string op)(Vector3 rhs) if (op == "*")
    {
        float[3] tmp = v[].dup;
        float value = 0;
        for (int i = 0; i < 3; ++i) {
            value += tmp[i] * rhs.v[i];
        }
        return value;
    }

    /// cross | dot | add | subtract on self
    Vector3 opOpAssign(string op)(Vector3 rhs)
    {
        v = opBinary!op(rhs).v;
        return this;
    }

    /// scalar multiply on self
    Vector3 opOpAssign(string op)(float rhs)
    {
        v = opBinary!op(rhs).v;
        return this;
    }

    /// index operator
    ref float opIndex(uint i)
    {
        return v[i];
    }

    /// overide opEquals
    bool opEquals(Vector3 rhs)
    {
        for (int i = 0; i < 3; ++i) {
            if (!approxEqual(v[i], rhs.v[i], 1e-4, 1e-5)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Object overides
     */
    string toString()
    {
        return to!string(v[]);
    }
}

// unittest constructors
unittest
{
    auto q = Vector3([1, 1, 1]);

    auto v0 = Vector3();
    auto v1 = Vector3(7, 3, 9);
    auto v2 = Vector3([7, 12, 11]);
    assert(v0.v == [0, 0, 0]);
    assert(v1.v == [7, 3, 9]);
    assert(v0.toString() == "[0, 0, 0]");
    assert(v1.toString() == "[7, 3, 9]");
    assert(v2.v == [7, 12, 11]);

    assert(is( typeof(v0) == Vector3));
    writeln("Vector3 constructor unittest passed");
}

// unittest methods
unittest
{
    auto v = Vector3(4, 7, 8);
    v.invert();
    assert(v.toString() == "[-4, -7, -8]");
    v.invert();
    assert(v.magnitude >= 11.3578f && v.magnitude <= 11.3579f);
    v.normalize();
    assert(v.toString() == "[0.35218, 0.616316, 0.704361]");
    assert((v.crossProduct(v)).v == [0, 0, 0]);

    auto v2 = Vector3([2, 1, 2]);
    auto v3 = Vector3([4, 10, 8]);
    auto vCPM = v2.crossProduct(v3);
    auto vCPO = v2 % v3;
    assert(vCPM == vCPO);

    v2.addScaledVector(v3, 3);
    assert(v2.v == [14, 31, 26]);
    assert(v3.v == [4, 10, 8]);

    auto v4 = v3.componentProduct(v2);
    assert(v4.v == [56, 310, 208]);
    assert(v2.v == [14, 31, 26]);
    assert(v3.v == [4, 10, 8]);

    v3.componentProductUpdate(v4);
    assert(v3.v == [224, 3100, 1664]);
    assert(v4.v == [56, 310, 208]);

    v4.clear();
    assert(v4.v == [0, 0, 0]);

    writeln("Vector3 method unittest passed");
}

// unittest operator overloads
unittest
{
    auto v_ = Vector3();
    auto q_ = Vector3();
    assert(v_ == q_);

    auto v = Vector3(2, 4, 6);
    auto q = Vector3(5, 7, 9);
    auto s = Vector3(5, 7, 9);

    auto boolChk  = (s == q);
    auto boolChk2 = (s != v);
    assert(boolChk);
    assert(boolChk2);

    // --- addition subtractions
    q -= v;
    v += q;
    assert(q.v == [3, 3, 3]);
    assert(v.v == [5, 7, 9]);

    auto a = q - v;
    assert(a.v == [-2, -4, -6]);
    assert(q.v == [3, 3, 3]);
    assert(v.v == [5, 7, 9]);

    auto d = v + a;
    assert(d.v == [3, 3, 3]);
    assert(a.v == [-2, -4, -6]);
    assert(q.v == [3, 3, 3]);
    assert(v.v == [5, 7, 9]);

    // --- vector product / cross product
    auto r = v % q;
    assert(r.v == [-6, 12, -6]);
    assert(q.v == [3, 3, 3]);
    assert(v.v == [5, 7, 9]);

    r %= v;
    assert(r.v == [150, 24, -102]);
    assert(r[1] == 24);
    r[1] += 1;
    assert(r.v == [150, 25, -102]);
    r[1] -= 1;
    assert(r.v == [150, 24, -102]);
    assert(v.v == [5, 7, 9]);

    // --- Multiplications
    auto x = r * q;
    assert(x == 216);
    assert(r.v == [150, 24, -102]);
    assert(q.v == [3, 3, 3]);
    auto opEq = Vector3(3, 3, 3);
    assert(q == opEq);

    auto n = Vector3(2, 2, 2);
    auto m = n * 4.0;
    assert(m.v == [8, 8, 8]);
    assert(n.v == [2, 2, 2]);

    m *= 2;
    assert(m.v == [16, 16, 16]);

    writeln("Vector3 operator overload unittest passed");
}