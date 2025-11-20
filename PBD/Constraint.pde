
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
    // Distancia actual entre partículas
    float dist = vd.mag();
    if(dist < 1e-6) return; // Evitar división por cero (posiciones casi coincidentes)

    // C = ||x_i - x_j|| - d  (función de restricción)
    C = dist - d;

    // n = (x_i - x_j) / ||x_i - x_j||  (gradiente con respecto a x_i)
    PVector n = vd.copy().div(dist);

    // Pesos (w) son las masas inversas: w = 1/mass; w == 0 => bloqueada
    float w1 = part1.w; // w_i
    float w2 = part2.w; // w_j
    float denom = w1 + w2; // (w_i + w_j)
    if(denom == 0) return; // ambos bloqueados

    // Factor escalar que aparece en las fórmulas.
    // En la diapositiva original la corrección es:
    //   Δp_i = - (w_i / (w_i + w_j)) * (||x_i - x_j|| - d) * n
    //   Δp_j =  (w_j / (w_i + w_j)) * (||x_i - x_j|| - d) * n
    // Aquí incluimos además el coeficiente de rigidez k' calculado en compute_k_coef():
    float lambda = k_coef * C; // k' * C

    // Δp_i (vector) = - (w1/denom) * lambda * n
    PVector dp_i = PVector.mult(n, - (w1 / denom) * lambda);
    // Δp_j (vector) = (w2/denom) * lambda * n
    PVector dp_j = PVector.mult(n, (w2 / denom) * lambda);

    // Aplicar correcciones (no mover partículas bloqueadas w==0)
    if (w1 > 0)
      part1.location.add(dp_i);
    if (w2 > 0)
      part2.location.add(dp_j);
  }
  
  void display(float scale_px){
    PVector p1 = particles.get(0).location; 
    PVector p2 = particles.get(1).location; 
    strokeWeight(3);
    stroke(255,255*(1-abs(4*C/d)),255*(1-abs(4*C/d)));
    line(scale_px*p1.x, -scale_px*p1.y, scale_px*p1.z,  scale_px*p2.x, -scale_px*p2.y, scale_px*p2.z);
  };
 
  
}
