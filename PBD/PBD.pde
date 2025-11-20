import peasy.*;

PeasyCam cam;
float scale_px = 1000;

boolean debug = false;

PBDSystem system;

float dt = 0.02;

PVector vel_viento= new PVector(0,0,0);

// Control de simulación
boolean paused = false;
int sim_n_iters = 80;

// Esfera oscilante
// Temporalmente desactivada: comentar la variable para evitar uso
// Esfera esfera;

//modulo de la intensidad del viento
float viento;


// Propiedades tela
float ancho_tela = 0.5;
float alto_tela = 0.5;
int n_ancho_tela = 10;
int n_alto_tela = 10;
float densidad_tela = 0.03; // kg/m^2 Podría ser tela gruesa de algodón, 100g/m^2
float sphere_size_tela = ancho_tela/n_ancho_tela*0.4;
float stiffness = 0.95;


void setup(){

  size(1080,720,P3D);

  cam = new PeasyCam(this,scale_px);
  cam.setMinimumDistance(1);
  // OJO!! Se le cambia el signo a la y, porque los px aumentan hacia abajo
  cam.pan(0.5*ancho_tela*scale_px, - 0.5*alto_tela*scale_px);
  
  
  system = crea_tela(alto_tela,
                      ancho_tela,
                      densidad_tela,
                      n_alto_tela,
                      n_ancho_tela,
                      stiffness,
                      sphere_size_tela);
                      
  system.set_n_iters(sim_n_iters);
  
  // Inicializar esfera oscilante
  // Código de la esfera comentado temporalmente
  // float esfera_radius = 0.25;      // radio en metros
  // float esfera_z_base = 0.15;      // altura base (m)
  // float esfera_amplitude = 0.10;   // amplitud de oscilación (m)
  // float esfera_speed = 1.0;        // velocidad angular (rad/s)
  // esfera = new Esfera(esfera_radius,
  //                      esfera_z_base, 
  //                      esfera_amplitude, 
  //                      esfera_speed, 
  //                      system, 
  //                      scale_px);
  
}

void aplica_viento(){
  // Aplicamos una fuerza que es proporcional al área.
  // No calculamos la normal. Se deja como ejercicio
  // El área se calcula como el área total, entre el número de partículas
  int npart = system.particles.size();
  float area_total = ancho_tela*alto_tela;
  float area = area_total/npart;
  for(int i = 0; i < npart; i++){
    float x = (0.5 + random(0.5))*vel_viento.x * area;
    float y = (0.5 + random(0.5))*vel_viento.y * area;
    float z = (0.5 + random(0.5))*vel_viento.z * area;
    PVector fv = new PVector(x,y,z); 
    system.particles.get(i).force.add(fv);
  }
  
  
}

void draw(){
  background(20,20,55);
  lights();

  if(!paused){
    system.apply_gravity(new PVector(0.0,-0.98,0.0));
    aplica_viento();
    system.run(dt);  
    // Actualiza posición de la esfera oscilante y aplica colisiones
    // Llamadas a la esfera desactivadas temporalmente
    // esfera.update(frameCount*dt);
    // esfera.applyCollision();
  }

  display();

  stats();
  
}



void stats(){
  

//escribe en la pantalla el numero de particulas actuales
  int npart = system.particles.size();
  fill(255);
  text("Frame-Rate: " + int(frameRate), -175, 15);
  text("Partículas: " + npart, -175, 155);

  text("Vel. Viento=("+vel_viento.x+", "+vel_viento.y+", "+vel_viento.x+")",-175,35);
  text("s - Arriba",-175,55);
  text("x - Abajo",-175,75);
  text("c - Derecha",-175,95);
  text("z - Izquierda",-175,115);

  // Estado de la simulación
  if(paused)
    text("Estado: PAUSADO (P para reanudar)",-175,135);
  else
    text("Estado: EJECUTANDO (P para pausar)",-175,135);



 //--->lo mismo se puede indicar para el viento
}

void display(){
  int npart = system.particles.size();
  int nconst = system.constraints.size();

  for(int i = 0; i < npart; i++){
    system.particles.get(i).display(scale_px);
  }
  
  for(int i = 0; i < nconst; i++)
      system.constraints.get(i).display(scale_px);
      
  // Dibujar esfera oscilante
  // Llamada a display de la esfera desactivada temporalmente
  // esfera.display();
}



//Podeis usar esta funcion para controlar el lanzamiento del castillo
//cada vez que se pulse el ratón se lanza otro cohete
//puede haber simultaneamente varios cohetes  (castillo = vector de cohetes )
void mousePressed(){
  // Click no usado actualmente. Reservado para futuras interacciones.
}
void keyPressed()
{
 // Tipo de fuegos
 if(key == '1'){
    println(key);
 }
 
 // Pausar / reanudar
 if(key == 'P' || key == 'p'){
   paused = !paused;
   println("Paused = "+paused);
 }

 // Reiniciar simulación
 if(key == 'R' || key == 'r'){
   reinitSimulacion();
 }
 // Viento
  if(key == 'Y'){
    vel_viento.y -= 0.001;
  }else if(key == 'y'){
    vel_viento.y += 0.001;
  }else if(key == 'z'){
    vel_viento.z -= 0.001;
  }else if(key == 'Z'){
    vel_viento.z += 0.001;
  }else if(key == 'X'){
    vel_viento.x += 0.001;
  }else if(key == 'x'){
    vel_viento.x -= 0.001;
  }
  
}  

// Re-inicializa la simulación (recrea la tela y resetea parámetros relevantes)
void reinitSimulacion(){
  println("Reiniciando simulación...");
  // Reset viento
  vel_viento = new PVector(0,0,0);
  // Recrear sistema
  system = crea_tela(alto_tela,
                      ancho_tela,
                      densidad_tela,
                      n_alto_tela,
                      n_ancho_tela,
                      stiffness,
                      sphere_size_tela);
  system.set_n_iters(sim_n_iters);
}