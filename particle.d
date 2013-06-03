/**
 *  Implementation of the particle class from Game Physiscs Engine Development
 */

module particle;

import std.stdio, std.math, std.conv, std.traits;
import vector3;

private immutable Vector3 _g_accel = Vector3(0, -10, 0);

/*
 * Simple particle (point mass)
 */
struct Particle
{
    alias Vector = Vector3;

    Vector position     = Vector(0, 0, 0);
    Vector velocity     = Vector(0, 0, 0);
    Vector acceleration = _g_accel;

    /* store the inverse mass since it makes representing mass extremes easier:
     * if infinite invMass = 0, zero mass = very big...
     * Accessor fucntions to control this property */
    float inverseMass = 1.0f;

    /* Holds the ammount of damping applied to linear motion.
     * Damping is required to remove the energy added through
     * numerical instabilities in the integrator.
     * (Game Physics Engine Development by Ian Millington) */
    float damping = 0.995f;

    Vector forceAccumulation = _g_accel;

    // CONSTRUCTOR
    this (Vector pos,
          Vector vel,
          Vector accel   = _g_accel,
          float  iMass   = 1.0f,
          float  damping = 0.995f)
    {
        this.position     = pos;
        this.velocity     = vel;
        this.acceleration = accel;
        this.inverseMass  = iMass;
        this.damping      = damping;

        // init accumulator
        this.forceAccumulation = accel;
    }

    /*---------------------------------------------
     * METHODS
     *-------------------------------------------*/
    float mass()
    {
        if (inverseMass == 0) {
            return float.max;
        }
        else {
            return (1/inverseMass);
        }
    }

    float mass(float value)
    {
        assert(value != 0);
        return inverseMass = 1/value;
    }

    bool hasFiniteMass()
    {
        return (inverseMass >= 0.0f);
    }

    void integrate(float timeStep)
    {
        assert(timeStep > 0);
        writeln(forceAccumulation);

        // update linear position
        position.addScaledVector(velocity, timeStep);

        // calculate acceleration from force
        Vector resultingAcceleration = acceleration;
        resultingAcceleration.addScaledVector(forceAccumulation, inverseMass);

        // update linear velocity
        velocity.addScaledVector(resultingAcceleration, timeStep);

        // impose drag
        velocity *= std.math.pow(damping, timeStep);
        writeln(forceAccumulation);
    }

    void clearAccumulator()
    {
        forceAccumulation.clear();
    }

    void addForce(Vector force)
    {
        forceAccumulation += force;
    }

    /* Object method overrides */
    string toString()
    {
        string particle_str = "Particle:\n";
        particle_str ~= "  position: "          ~ position.toString()          ~ "\n";
        particle_str ~= "  velocity: "          ~ velocity.toString()          ~ "\n";
        particle_str ~= "  acceleration: "      ~ acceleration.toString()      ~ "\n";
        particle_str ~= "  inverseMass: "       ~ to!string(inverseMass)       ~ "\n";
        particle_str ~= "  forceAccumulation: " ~ forceAccumulation.toString() ~ "\n";
        return particle_str;
    }
}

unittest
{
    auto p1         = Particle();
    auto nullVector = Vector3([0, 0, 0]);
    auto gravity    = Vector3([0, -10, 0]);

    assert(p1.position            == nullVector);
    assert(p1.velocity            == nullVector);
    assert(p1.acceleration        == gravity);
    assert(p1.damping             == 0.995f);
    assert(p1.inverseMass         == 1);
    assert(p1.mass                == 1);
    assert(p1.forceAccumulation   == gravity);

    auto pos = Vector3(12.14, -134.79, 200);
    auto vel = Vector3(3000, -1.99, 0);
    auto p2  = Particle(pos, vel);

    assert(p2.position          == Vector3([12.14, -134.79, 200]));
    assert(p2.velocity          == Vector3([3000, -1.99, 0]));
    assert(p2.acceleration      == Vector3([0, -10, 0]));
    assert(p2.damping           == 0.995f);
    assert(p2.inverseMass       == 1);
    assert(p2.mass              == 1);
    assert(p2.forceAccumulation == Vector3([0, -10, 0]));

    writeln("Particle constructor unittest passed");
}

unittest
{
    auto pos   = Vector3(10, 10.111, 300);
    auto vel   = Vector3(300, -2.876221, 0);
    auto accel = Vector3(1, -14, 22);
    auto p1    = Particle(pos, vel, accel, 0.3, 0.9);
    auto wind  = Vector3([100, 3.4447, 0]);
    p1.addForce(wind);
    p1.integrate(0.3);

    assert(p1.position          == Vector3([100, 9.24813, 300]));
    assert(p1.velocity          == Vector3([299.764, -7.77647, 8.31304]));
    assert(p1.acceleration      == Vector3([1, -14, 22]));
    assert(p1.forceAccumulation == Vector3([101, -10.5553, 22]));

    writeln("Particle methods unittest passed");
}