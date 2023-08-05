

class Grid {

    //------------------------Properties/Fields------------------------------------
    
    // -------- mouse interaction --------
    int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
    float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY;
    boolean mouseInWindow = false;
    
    color[] defaultColors = {color(12,248,165)};
    color[] colors;
    
    int maxCount = 5;
    int xCount = 2;
    int yCount = 2;
    int zCount = 2;


    Node[][][] nodes;
    PVector[][][] targets;
    float[][][] prevYs;
}