

class Node extends PVector {
  //---------------------PROPERTIES/FIELDS/PARAMETERS---------------------------
  String id = "";
  float diameter = 0;
  
  float minX = -Float.MAX_VALUE;
  float maxX = Float.MAX_VALUE;
  float minY = -Float.MAX_VALUE;
  float maxY = Float.MAX_VALUE;
  float minZ = -Float.MAX_VALUE;
  float maxZ = Float.MAX_VALUE;
  
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  PVector pVelocity = new PVector();
  PVector target = new PVector();
  
  PVector dir, steer;
  
  float maxVelocity = 40;
  float midVelocity = 20;
  float damping = 0.5;
  float radius = 200;
  float strength = -1;
  float ramp = 1.0f;
  float scale = 0.75f;
  
  //----------------------------CONSTRUCTORs------------------------------------
  Node() {
  }
  
  Node(float theX, float theY) {
    x = theX;
    y = theY;
  }
  
  Node(float theX, float theY, float theZ) {
    x = theX;
    y = theY;
    z = theZ;
  }
  
  Node(PVector theVector) {
    x = theVector.x;
    y = theVector.y;
    z = theVector.y;
  }
  
  // --- rotate position around origin
  void rotateX(float theAngle) {
    float newy = y * cos(theAngle) - z * sin(theAngle);
    float newz = y * sin(theAngle) + z * cos(theAngle);
    y = newy;
    z = newz;
  }
  
  void rotateY(float theAngle) {
    float newx = x * cos(-theAngle) - z * sin(-theAngle);
    float newz = x * sin(-theAngle) + z * cos(-theAngle);
    x = newx;
    z = newz;
  }
  
  void rotateZ(float theAngle) {
    float newx = x * cos(theAngle) - y * sin(theAngle);
    float newy = x * sin(theAngle) + y * cos(theAngle);
    x = newx;
    y = newy;
  }
  
  //----------------------------METHODS-----------------------------------------
  
  void attract(Node[] theNodes) {
    for (int i = 0; i < theNodes.length; i++) {
      Node otherNode = theNodes[i];
      if (otherNode == null) break;
      if (otherNode == this) continue;
      this.attract(otherNode);
    }
  }
  
  void attract(Node theNode) {
    float d = PVector.dist(this, theNode);
    if (d > 0 && d < radius) {
      float s = pow(d/radius, 1/ramp);
      float f = s * 9 * strength * (1/(s+1) + ((s-3)/4))/d;
      PVector df = PVector.sub(this, theNode);
      df.mult(f);
      
      theNode.velocity.x += df.x;
      theNode.velocity.y += df.y;
      theNode.velocity.z += df.z;
    }
  }
  
  void update() {
    velocity.limit(maxVelocity);
    
    x += velocity.x;
    y += velocity.y;
    z += velocity.z;
    
    if (x < minX) {
     x = minX - (x-minX);
     velocity.x = -velocity.x;
    }
    if (x > maxX) {
      x = maxX - (x-maxX);
      velocity.x = -velocity.x;
    }
    if (y < minY) {
      y = minY - (y - minY);
      velocity.y = -velocity.y;
    }
    if (y > maxY) {
      y = maxY - (y - maxY);
      velocity.y = -velocity.y;
    }
    if (z < minZ) {
      z = minZ - (z - minZ);
      velocity.z = -velocity.z;
    }
    if (z > maxZ) {
      z = maxZ - (z - maxZ);
      velocity.z = -velocity.z;
    }
    
    velocity.mult(1-damping);
  }
  
  void update(PVector theTarget) {
    velocity.limit(maxVelocity);
    
    target = theTarget.get();
    dir = PVector.sub(target, this);
    float d = PVector.dist(target, this);
    
    dir.normalize();
    if (d < radius) {
      float speedMap = map(d, 0,radius, 0,maxVelocity);
      dir.mult(speedMap);
    }
    else {
      d /= radius;
      float speed = midVelocity + d + pow(d, scale);
      dir.mult(speed);
    }
    
    steer = PVector.sub(dir, velocity);
    acceleration.add(steer);
    
    velocity.add(acceleration);
    x += velocity.x;
    y += velocity.y;
    z += velocity.z;
    
    //Boundaries
    if (x < minX) {
     x = minX - (x-minX);
     velocity.x = -velocity.x;
    }
    if (x > maxX) {
      x = maxX - (x-maxX);
      velocity.x = -velocity.x;
    }
    if (y < minY) {
      y = minY - (y - minY);
      velocity.y = -velocity.y;
    }
    if (y > maxY) {
      y = maxY - (y - maxY);
      velocity.y = -velocity.y;
    }
    if (z < minZ) {
      z = minZ - (z - minZ);
      velocity.z = -velocity.z;
    }
    if (z > maxZ) {
      z = maxZ - (z - maxZ);
      velocity.z = -velocity.z;
    }
    
    
    acceleration.mult(0);
  }
  
  //----------Getters and Setters----------------------
  String getID() {
    return id;
  }
  
  void setID(String theID) {
    this.id = theID;
  }
  
  float getDiameter() {
    return diameter;
  }
  
  void setDiameter(float theMinX, float theMinY, float theMinZ, float theMaxX,
  float theMaxY, float theMaxZ){
    this.minX = theMinX;
    this.maxX = theMaxX;
    this.minY = theMinY;
    this.maxY = theMaxY;
    this.minZ = theMinZ;
    this.maxZ = theMaxZ;
  }
  
  void setBoundary(float theMinX, float theMinY, float theMaxX, float theMaxY) {
    this.minX = theMinX;
    this.maxX = theMaxX;
    this.minY = theMinY;
    this.maxY = theMaxY;
  }
  
  float getMinX() {
    return minX;
  }
  
  void setMinX(float theMinX) {
    this.minX = theMinX;
  }
  
  float getMaxX() {
    return maxX;
  }
  
  void setMaxX(float theMaxX) {
    this.maxX = theMaxX;
  }
  
  float getMinY() {
    return minY;
  }
  
  void setMinY(float theMinY) {
    this.minY = theMinY;
  }
  
  float getMaxY() {
    return maxY;
  }
  
  void setMaxY(float theMaxY) {
    this.maxY = theMaxY;
  }
  
  float getMinZ(){
    return minZ;
    
  }
  void setMinZ(float theMinZ) {
    this.minZ = theMinZ;
  }
  
  float getMaxZ() {
    return maxZ;
  }
  
  void setMaxZ(float theMaxZ) {
    this.maxZ = theMaxZ;
  }
  
  PVector getVelocity() {
    return velocity;
  }
  
  void setVelocity(PVector theVelocity) {
    this.velocity = theVelocity;
  }
  
  float getMaxVelocity() {
    return maxVelocity;
  }
  
  void setMaxVelocity(float theMaxVelocity) {
    this.maxVelocity = theMaxVelocity;
  }
  
  //-----NEW ------ midVelocity!!!!!!!---------
  float getMidVelocity() {
    return midVelocity;
  }
  
  void setMidVelocity(float theMidVelocity) {
    this.midVelocity = theMidVelocity;
  }
  
  //------!!!!!! -------- ADDITION --------
  //can SET the 'scale' of the TARGET Vector:
  float getScale() {
    return scale;
  }
  
  void setScale(float theScale) {
    this.scale = theScale;
  }
  
  float getDamping() {
    return damping;
  }
  
  void setDamping(float theDamping) {
    this.damping = theDamping;
  }
  
  float getRadius() {
    return radius;
  }
  
  void setRadius(float theRadius) {
    this.radius = theRadius;
  }
  
  float getStrength() {
    return strength;
  }
  
  void setStrength(float theStrength) {
    this.strength = theStrength;
  }
  
  float getRamp() {
    return ramp;
  }
  
  void setRamp(float theRamp) {
    this.ramp = theRamp;
  }
}
