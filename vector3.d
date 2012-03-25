/**
 *  Implementation of the Vector3 class from Game Physiscs Engine Development
 */

module vector3;
 
import std.stdio, std.math, std.conv, std.traits;

struct Vector3(T)
  if (isFloatingPoint!T)
{
    alias Vector3!T Vector; 

    /// vector data: x = 0, y = 1, z = 2... as one would hopefully expect...
    T[3] v = [0, 0, 0];
    
    this (T[] v_in) {
        v[] = v_in;
    }

    this (T x, T y, T z) {
        v[0] = x;
        v[1] = y;
        v[2] = z;
    }
    
    /**
     * METHODS 
     */
    void invert() { v[] *= -1; }
    
    /// magnitude: Pythagoras theorm for 3D
    T magnitude() { return std.math.sqrt(squareMagnitude()); }
    
    T squareMagnitude() {
        T m2 = 0;
        foreach(i; v) {
            m2 += i*i;
        }
        
        return m2;
    }
    
    void normalize() {
        T n = magnitude();
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
    void addScaledVector(ref Vector b, T scale) {
        v[] += (b * scale).v[];
    }
    
    void clear() {
        v = [0, 0, 0];
    }
    
    /**
     * component product
     * Params:
     *  b = Vector3 to operate on
     * Returns:
     *  Vector3 who's components are multiple of this vector and b's
     */
    Vector componentProduct(ref Vector b) {
        auto tmp = v[].dup;
        tmp[] *= b.v[];
        return Vector(tmp);
    }
    
    void componentProductUpdate(ref Vector b) {
        v[] *= b.v[];
    }
    
    Vector crossProduct(ref const Vector b) {
        return Vector((v[1] * b.v[2]) - (v[2] * b.v[1]),
                       (v[2] * b.v[0]) - (v[0] * b.v[2]),
                       (v[0] * b.v[1]) - (v[1] * b.v[0]));
    }
    
    /**
     * OPERATORS
     */
    /// scalar multiplication
    Vector opBinary(string op)(T rhs) if (op == "*") {
        auto tmp = v[].dup;
        tmp[] *= rhs;
        return (Vector(tmp));        
    }

    /// cross product
    Vector opBinary(string op)(ref Vector rhs) if (op == "%") {
        return Vector((v[1] * rhs.v[2]) - (v[2] * rhs.v[1]),
                       (v[2] * rhs.v[0]) - (v[0] * rhs.v[2]),
                       (v[0] * rhs.v[1]) - (v[1] * rhs.v[0]));        
    }
    
    /// dot product
    T opBinary(string op)(ref Vector rhs) if (op == "*") {
        auto tmp = v[].dup;
        T value = 0;
        for (int i = 0; i < 3; i++) {
            value += tmp[i] * rhs.v[i];
        }
        return value;
    }
    
    /// add vector
    Vector opBinary(string op)(ref Vector rhs) if (op == "+") {
        auto tmp = v[].dup;
        tmp[] += rhs.v[];
        return (Vector(tmp));     
    }
    
    /// subtract vector
    Vector opBinary(string op)(ref Vector rhs) if (op == "-") {
        auto tmp = v[].dup;
        tmp[] -= rhs.v[];
        return (Vector(tmp));     
    }

    /// cross | dot | add | subtract on self
    ref Vector opOpAssign(string op)(ref Vector rhs) {
        v = opBinary!op(rhs).v;
        return this;
    }
    
    /// scalar multiply on self
    ref Vector opOpAssign(string op)(T rhs) {
        v = opBinary!op(rhs).v;
        return this;
    }    
    
    /// index operator
    ref T opIndex(uint i) { return v[i]; }
    
    /// overide opEquals
    bool opEquals(ref Vector rhs) {
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
    string toString() { return T.stringof ~ to!string(v[]); }
}

// unittest constructors
unittest
{
    auto q = Vector3!real([1, 1, 1]);

    auto v0 = Vector3!double();
    auto v1 = Vector3!float(7, 3, 9);
    auto v2 = Vector3!real([7, 12, 11]);
    assert(v0.v == [0, 0, 0]);
    assert(v1.v == [7, 3, 9]);
    assert(v0.toString() == "double[0, 0, 0]");
    assert(v1.toString() == "float[7, 3, 9]");
    assert(v2.v == [7, 12, 11]);
    
    assert(is( typeof(v0) == Vector3!double));
    writeln("Vector3 constructor unittest passed\n", q);
}

// unittest methods
unittest
{
    auto v = Vector3!real(4, 7, 8);   
    v.invert();
    assert(v.toString() == "real[-4, -7, -8]");
    v.invert();   
    assert(v.magnitude() >= 11.3578f && v.magnitude <= 11.3579f);   
    v.normalize();
    assert(v.toString() == "real[0.35218, 0.616316, 0.704361]");
    assert((v.crossProduct(v)).v == [0, 0, 0]);
    
    auto v2 = Vector3!double([2, 1, 2]);
    auto v3 = Vector3!double([4, 10, 8]);
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
    
    writeln("Vector3 method unittest passed\n", v4); 
}

// unittest operator overloads
unittest
{
    auto v = Vector3!real(2, 4, 6);
    auto q = Vector3!real(5, 7, 9);
    auto s = Vector3!real(5, 7, 9);
    
    auto boolChk = (s == q);
    auto boolChk2 = (s != v);
    assert(boolChk);
    assert(boolChk2);
    
    // --- addition subtractions ---
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
    // -----------------------------
    
    // --- vector product / cross product ---
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
    // ---------------------------------------
    
    // --- Multiplications ---
    auto x = r * q;
    assert(x == 216);
    assert(r.v == [150, 24, -102]);   
    assert(q.v == [3, 3, 3]);    
    
    auto n = Vector3!double(2, 2, 2);
    auto m = n * 4.0;
    assert(m.v == [8, 8, 8]);
    assert(n.v == [2, 2, 2]);
    
    m *= 2;
    assert(m.v == [16, 16, 16]);
    // -----------------------
    
    writeln("Vector3 operator overload unittest passed\n", m);
}