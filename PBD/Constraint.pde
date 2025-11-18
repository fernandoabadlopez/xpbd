
abstract class Constraint{

  ArrayList<Particle> particles;
  float stiffness;    // k en el paper de Muller
  float k_coef;       // k' en el paper de Muller
  float C;
  
  Constraint(){
    particles = new ArrayList<Particle>();
  }
  
  void  compute_k_coef(int n){
    k_coef = 1.0 - pow((1.0-stiffness),1.0/float(n));
    println("Fijamos "+n+" iteraciones   -->  k = "+stiffness+"    k' = "+k_coef+".");
  }

  abstract void proyecta_restriccion();
  abstract void display(float scale_px);
}

class DistanceConstraint extends Constraint{

  float d;
  
  DistanceConstraint(Particle p1,Particle p2,float dist,float k){
    super();
    d = dist;
    particles.add(p1);
    particles.add(p2);
    stiffness = k;
    k_coef = stiffness;
    C=0;

  }
  
  void proyecta_restriccion(){
    Particle part1 = particles.get(0); 
    Particle part2 = particles.get(1);
    
    PVector vd = PVector.sub(part1.location,part2.location);

    if(debug){
      println("PROYECTA: p1="+part1.location);
      println("PROYECTA: p2="+part2.location);
      println("PROYECTA: p1-p2="+vd);
    }
    
    /**
     * COMPLETAR RESTRICCION
     * */
    float dist = vd.mag();
    if(dist == 0) return; // Evitar división por cero

    // C = |x1 - x2| - d
    C = dist - d;

    // Normalizado desde part2 hacia part1
    PVector n = vd.copy().div(dist);

    // Pesos (w) son las masas inversas: w = 1/mass; w == 0 => bloqueada
    float w1 = part1.w;
    float w2 = part2.w;
    float denom = w1 + w2;
    if(denom == 0) return; // ambos bloqueados

    // Corrección según PBD: desplazar proporcionalmente a w_i/denom
    // k_coef ya contiene el coeficiente corregido para el número de iteraciones
    PVector corr = PVector.mult(n, (k_coef * C) / denom);

    if(w1 > 0)
      part1.location.sub(PVector.mult(corr, w1));
    if(w2 > 0)
      part2.location.add(PVector.mult(corr, w2));
  }
  
  void display(float scale_px){
    PVector p1 = particles.get(0).location; 
    PVector p2 = particles.get(1).location; 
    strokeWeight(3);
    stroke(255,255*(1-abs(4*C/d)),255*(1-abs(4*C/d)));
    line(scale_px*p1.x, -scale_px*p1.y, scale_px*p1.z,  scale_px*p2.x, -scale_px*p2.y, scale_px*p2.z);
  };
 
  
}
