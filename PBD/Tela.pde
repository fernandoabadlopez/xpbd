

PBDSystem crea_tela(float alto,
    float ancho,
    float dens,
    int n_alto,
    int n_ancho,
    float stiffness,
    float display_size){
   
  int N = n_alto*n_ancho;
  float masa = dens*alto*ancho;
  PBDSystem tela = new PBDSystem(N,masa/N);
  
  float dx = ancho/(n_ancho-1.0);
  float dy = alto/(n_alto-1.0);
  
  int id = 0;
  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      Particle p = tela.particles.get(id);
      p.location.set(dx*i,dy*j,0);
      p.display_size = display_size;

      id++;
    }
  }
  
  /**
   * Creo restricciones de distancia. Aquí sólo se crean restricciones de estructura.
   * Faltarían las de shear y las de bending.
   */
  id = 0;
  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      println("id: "+id+" (i,j) = ("+i+","+j+")");
      Particle p = tela.particles.get(id);
      if(i>0){
        int idx = id - n_alto;
        Particle px = tela.particles.get(idx);
        Constraint c = new DistanceConstraint(p,px,dx,stiffness);
        tela.add_constraint(c);
        println("Restricción creada: "+ id+"->"+idx);
      }

      if(j>0){
        int idy = id - 1;
        Particle py = tela.particles.get(idy);
        Constraint c = new DistanceConstraint(p,py,dy,stiffness);
        tela.add_constraint(c);
        println("Restricción creada: "+ id+"->"+idy);
      }

      id++;
    }
  }
  
  // Fijamos dos esquinas
  id = n_alto-1;
  tela.particles.get(id).set_bloqueada(true); 
  
  id = N-1;
  tela.particles.get(id).set_bloqueada(true); 
  
  print("Tela creada con " + tela.particles.size() + " partículas y " + tela.constraints.size() + " restricciones."); 
  
  return tela;
}
