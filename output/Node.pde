
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
    float damping = 0.5f;
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
    }
}

