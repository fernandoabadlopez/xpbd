// Clase Esfera: representa una esfera oscilante que interactúa con la tela
class Esfera {
  PVector pos;
  float radius_m;        // radio en metros
  float z_base_m;        // altura base sobre el plano de la tela (m)
  float amplitude_m;     // amplitud de oscilación (m)
  float speed;           // velocidad angular de oscilación (rad/s)
  boolean enabled;       // activar/desactivar
  
  PBDSystem system;      // referencia al sistema PBD para colisiones
  float scale_px;        // escala de píxeles (1000 px = 1 m)
  
  Esfera(float r, float z_base, float amp, float spd, PBDSystem sys, float scale) {
    radius_m = r;
    z_base_m = z_base;
    amplitude_m = amp;
    speed = spd;
    system = sys;
    scale_px = scale;
    enabled = true;
    pos = new PVector(0, 0, z_base_m);
  }
  
  // Actualiza la posición de la esfera según el tiempo (t en segundos)
  // Oscila en el eje Z alrededor de z_base_m
  void update(float t) {
    if (!enabled) return;
    
    float ancho_tela = 0.5;  // NOTA: estas variables debería obtenerlas del sistema
    float alto_tela = 0.5;   // Por ahora se asumen desde el sketch principal
    
    float cx = 0.5 * ancho_tela;  // centrada en X
    float cy = 0.5 * alto_tela;   // centrada en Y
    // Oscilación en Z alrededor de z_base_m
    float cz = z_base_m + amplitude_m * sin(speed * t);
    
    pos.set(cx, cy, cz);
  }
  
  // Proyección simple de colisión: empuja partículas fuera de la esfera
  void applyCollision() {
    if (!enabled || system == null) return;
    
    for (int i = 0; i < system.particles.size(); i++) {
      Particle p = system.particles.get(i);
      if (p.w == 0) continue; // bloqueada, no afectar
      
      PVector diff = PVector.sub(p.location, pos);
      float dist = diff.mag();
      
      if (dist == 0) {
        diff = new PVector(0, 1, 0);
        dist = 1e-6;
      }
      
      if (dist < radius_m) {
        // Empujar la partícula fuera de la esfera
        PVector n = diff.copy().div(dist);
        float targetDist = radius_m + 0.001; // pequeño epsilon
        PVector newPos = PVector.add(pos, PVector.mult(n, targetDist));
        p.location.set(newPos.x, newPos.y, newPos.z);
      }
    }
  }
  
  // Dibuja la esfera en pantalla
  void display() {
    if (!enabled || pos == null) return;
    
    pushMatrix();
      noStroke();
      fill(200, 50, 50, 150);
      translate(scale_px * pos.x,
                -scale_px * pos.y,  // OJO: se invierte Y porque los píxeles aumentan hacia abajo
                scale_px * pos.z);
      sphereDetail(30);
      sphere(scale_px * radius_m);
    popMatrix();
  }
  
  // Controla si la esfera está activada
  void setEnabled(boolean e) {
    enabled = e;
  }
  
  boolean isEnabled() {
    return enabled;
  }
}
