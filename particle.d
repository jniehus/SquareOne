/**
 *  Implementation of the particle class from Game Physiscs Engine Development
 */

module particle;
 
import std.stdio, std.math, std.conv, std.traits;
import vector3;

/*
 * Simple particle (point mass)
 */ 
class Particle(T) 
  if (isFloatingPoint!T)
{
    alias Vector3!T Vector;

    /*--------------------------------------------
     - Constructors
     -------------------------------------------*/
    this () {
        m_position          = Vector(0, 0, 0);
        m_velocity          = Vector(0, 0, 0);
        m_acceleration      = Vector(0, -10, 0); // -10 m/s^2
        m_damping           = 0.995f;
        m_inverseMass       = 1;
        m_forceAccumulation = m_acceleration; // starts out with gravity...
    }
    
    this (ref Vector pos, ref Vector vel, T invMass = 1, T dmp = 0.995) {
        m_position          = pos;
        m_velocity          = vel;
        m_acceleration      = Vector(0, -10, 0); // -10 m/s^2 gravity
        m_damping           = dmp;
        m_inverseMass       = invMass;
        m_forceAccumulation = m_acceleration;        
    }

    /*--------------------------------------------
     - Properties
     -------------------------------------------*/
    private Vector m_position;
    public {
      @property Vector position()                 { return m_position; }
      @property Vector position(ref Vector value) { return m_position = value; }
    }
    
    private Vector m_velocity;
    public {
      @property public Vector velocity()                 { return m_velocity; }
      @property public Vector velocity(ref Vector value) { return m_velocity = value; }        
    }
    
    private Vector m_acceleration;
    public {
      @property public Vector acceleration()                 { return m_acceleration; }
      @property public Vector acceleration(ref Vector value) { return m_acceleration = value; }        
    }

    /* Holds the ammount of damping applied to linear motion.
     * Damping is required to remove the energy added through
     * numerical instabilities in the integrator.
     * (Game Physics Engine Development by Ian Millington) */
    private T m_damping;
    public {
      @property public T damping()        { return m_damping; }
      @property public T damping(T value) { return m_damping = value; }
    }
     
    /* store the inverse mass since it makes representing mass extremes easier:
     * if infinite invMass = 0, zero mass = very big...
     * Accessor fucntions to control this property */
    private T m_inverseMass;
    public {
      @property public T inverseMass()        { return m_inverseMass; }   
      @property public T inverseMass(T value) { return m_inverseMass = value; } 
      
      @property T mass() {
        if (m_inverseMass == 0) {
          return T.max;
        }
        else {
          return (1/m_inverseMass);
        }
      }        
     
      @property T mass(T value) {
        assert(value != 0);
        return m_inverseMass = 1/value;
      }   
      
      bool hasFiniteMass() { return (m_inverseMass >= 0.0f); }
    }
    
    private Vector m_forceAccumulation;
        
    /*---------------------------------------------
     * METHODS
     *-------------------------------------------*/
    public {
      void integrate(T timeStep) {  
        assert(timeStep > 0);
        
        // update linear position
        m_position.addScaledVector(m_velocity, timeStep);
        
        // calculate acceleration from force
        Vector resultingAcceleration = m_acceleration;
        resultingAcceleration.addScaledVector(m_forceAccumulation, m_inverseMass);
        
        // update linear velocity
        m_velocity.addScaledVector(resultingAcceleration, timeStep);
        
        // impose drag
        m_velocity *= std.math.pow(damping, timeStep);
      }
     
      void clearAccumulator() {
        m_forceAccumulation.clear();
      }
    
      void addForce(Vector force) {
        m_forceAccumulation += force;
      } 
    }    
    
    /* Object method overrides */
    string toString() {
        string particleStr = "Particle!" ~ T.stringof ~ "\n";
        particleStr ~= "  position: "       ~ to!string(m_position) ~ "\n";
        particleStr ~= "  velocity: "       ~ to!string(m_velocity) ~ "\n";
        particleStr ~= "  acceleration: "   ~ to!string(m_acceleration) ~ "\n";
        particleStr ~= "  inverseMass: "    ~ to!string(m_inverseMass) ~ "\n";
        return particleStr;
    }
}

unittest
{
    auto p1         = new Particle!double();
    auto nullVector = Vector3!double([0, 0, 0]);
    auto gravity    = Vector3!double([0, -10, 0]);
    
    assert(p1.position            == nullVector);
    assert(p1.velocity            == nullVector);
    assert(p1.acceleration        == gravity);
    assert(p1.damping             == 0.995f);
    assert(p1.inverseMass         == 1);
    assert(p1.mass                == 1);
    assert(p1.m_forceAccumulation == gravity);
    
    auto pos = Vector3!real(12.14, -134.79, 200);
    auto vel = Vector3!real(3000, -1.99, 0);

    alias Particle!real RParticle; 
    auto p2 = new RParticle(pos, vel);
    
    assert(p2.position            == Vector3!real([12.14, -134.79, 200]));
    assert(p2.velocity            == Vector3!real([3000, -1.99, 0]));
    assert(p2.acceleration        == Vector3!real([0, -10, 0]));
    assert(p2.damping             == 0.995f);
    assert(p2.inverseMass         == 1);
    assert(p2.mass                == 1);
    assert(p2.m_forceAccumulation == Vector3!real([0, -10, 0])); 
     
    writeln("Particle constructor unittest passed. \n", p1);
}

unittest
{
    auto pos  = Vector3!float(10, 10.111, 300);
    auto vel  = Vector3!float(300, -2.876221, 0);
    auto p1   = new Particle!float(pos, vel, 0.3, 0.9);
    auto wind = Vector3!float([100, 3.4447, 0]);
    p1.addForce(wind);
    p1.integrate(0.3);
    
    assert(p1.position            == Vector3!float([100, 9.24813, 300]));
    assert(p1.velocity            == Vector3!float([299.386, -6.26501, 0]));
    assert(p1.acceleration        == Vector3!float([0, -10, 0]));
    assert(p1.m_forceAccumulation == Vector3!float([100, -6.5553, 0]));
    
    writeln("Particle methods unittest passed. \n", p1);
}

void main() {}