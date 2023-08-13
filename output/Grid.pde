

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

    int oldXCount;
    int oldYCount;
    int oldZCount;
    
    float gridStepX;
    float gridStepY;
    float gridStepZ;
    float oldGridStepX;
    float oldGridStepY;
    float oldGridStepZ;
    
    float nodeRadius = 200;
    float nodeRamp = 3.0;
    float nodeScale = 0.85;
    float nodeDamping = 0.2;
    
    boolean drawX = true;
    boolean drawY = true;
    boolean drawZ = true;
    
    float nodeMax;
    float nodeMid;
    
    boolean invertBackground = false;
    float lineWeight = 1.5;
    float lineAlpha = 50;
    
    boolean drawCurves = true;
    boolean drawLines = false;
    
    float gridBase;

    Node[][][] nodes;
    PVector[][][] targets;
    float[][][] prevYs;

    int stepI = 1;
    boolean lineDrawn = false;

    Grid() {
        println();
    }

    Grid(int theXCount, int theYCount, int theZCount) {
        maxCount = max(theXCount, theYCount, theZCount);
        xCount = theXCount;
        yCount = theYCount;
        zCount = theZCount;
    }

    Grid(int theXCount, int theYCount, int theZCount, float theGridStepX, float theGridStepY, float theGridStepZ,
            int theMaxCount, float theNodeMaxVelocity, float theNodeMidVelocity,
            float theNodeRadius, float theNodeRamp, float theNodeScale, float theNodeDamping,
            boolean theInvertBackground, float theLineWeight, float theLineAlpha,
            boolean theDrawX, boolean theDrawY, boolean theDrawZ, boolean theDrawCurves, float theGridBase) {
        colors = defaultColors;
        maxCount = theMaxCount;

        xCount = theXCount;
        yCount = theYCount;
        zCount = theZCount;

        oldXCount = theXCount;
        oldYCount = theYCount;
        oldZCount = theZCount;
        
        gridStepX = theGridStepX;
        gridStepY = theGridStepY;
        gridStepZ = theGridStepZ;
        
        nodeMax = theNodeMaxVelocity;
        nodeMid = theNodeMidVelocity;
        
        nodeRadius = theNodeRadius;
        nodeRamp = theNodeRamp;
        nodeScale = theNodeScale;
        nodeDamping = theNodeDamping;
        
        invertBackground = theInvertBackground;
        
        lineWeight = theLineWeight;
        lineAlpha = theLineAlpha;
        
        drawX = theDrawX;
        drawY = theDrawY;
        drawZ = theDrawZ;
        
        drawCurves = theDrawCurves;
        boolean theDrawLines = !theDrawCurves;
        drawLines = theDrawLines;

        nodes = new Node[maxCount*2+1][maxCount*2+1][maxCount*2+1];
        targets = new PVector[maxCount*2+1][maxCount*2+1][maxCount*2+1];
        prevYs = new float[maxCount*2+1][maxCount*2+1][maxCount*2+1];

        gridBase = theGridBase;
        initGrid(gridBase);
    }

    void reset() {
        colors = defaultColors;
        setParas(xCount,yCount,zCount, 29,200,100, 30,15, 100,3.125,1.325,0.7, false, 1,50, true,true,true, false);
        initGrid();
        
        targetRotationX = 0;
        targetRotationY = 0;
    }
    
    void setParas(int theXCount, int theYCount, int theZCount, float theGridStepX, float theGridStepY, float theGridStepZ,
    float theNodeMaxVelocity, float theNodeMidVelocity,
    float theNodeRadius, float theNodeRamp, float theNodeScale, float theNodeDamping,
    boolean theInvertBackground, float theLineWeight, float theLineAlpha,
    boolean theDrawX, boolean theDrawY, boolean theDrawZ, boolean theDrawCurves) {
        xCount = theXCount;
        yCount = theYCount;
        zCount = theZCount;
        
        oldXCount = theXCount;
        oldYCount = theYCount;
        oldZCount = theZCount;
        
        gridStepX = theGridStepX;
        gridStepY = theGridStepY;
        gridStepZ = theGridStepZ;
        
        nodeMax = theNodeMaxVelocity;
        nodeMid = theNodeMidVelocity;
        
        nodeRadius = theNodeRadius;
        nodeRamp = theNodeRamp;
        nodeScale = theNodeScale;
        nodeDamping = theNodeDamping;
        
        invertBackground = theInvertBackground;
        
        drawX = theDrawX;
        drawY = theDrawY;
        drawZ = theDrawZ;
        
        drawCurves = theDrawCurves;
        boolean theDrawLines = !theDrawCurves;
        drawLines = theDrawLines;
    }
    
    void initGrid() {
        float xPos, yPos, zPos;
        Node n;
        
        for (int iz = 0; iz < maxCount*2+1; iz++) {
            for (int iy = 0; iy < maxCount*2+1; iy++) {
                for (int ix = 0; ix < maxCount*2+1; ix++) {
                    xPos = (ix-maxCount)*gridStepX;
                    yPos = (iy-maxCount)*gridStepY;
                    zPos = (iz-maxCount)*gridStepZ;
                    
                    if (nodes[iz][iy][ix] == null) {
                        n = new Node(xPos, yPos, zPos);
                        n.minX = -20000;
                        n.maxX = 20000;
                        n.minY = -20000;
                        n.maxY = 20000;
                        n.minZ = -20000;
                        n.maxZ = 20000;
                    }
                    else {
                        n = nodes[iz][iy][ix];
                        n.x = xPos;
                        n.y = yPos;
                        n.z = zPos;
                        n.velocity.x = 0;
                        n.velocity.y = 0;
                        n.velocity.z = 0;
                    }
                    n.damping = nodeDamping;
                    n.scale = nodeScale;
                    n.radius = nodeRadius;
                    n.ramp = nodeRamp;
                    n.maxVelocity = nodeMax;
                    n.midVelocity = nodeMid;
                    nodes[iz][iy][ix] = n;
                    targets[iz][iy][ix] = new PVector(xPos, yPos, zPos);
                    prevYs[iz][iy][ix] = yPos;
                }
            }
        }
    }

    //-----------------------------Methods-----------------------------------------

    void initGrid(float theBase) {
        float xPos, yPos, zPos;
        Node n;
        for (int iz = 0; iz < maxCount*2+1; iz++) {
            for (int iy = 0; iy < maxCount*2+1; iy++) {
                for (int ix = 0; ix < maxCount*2+1; ix++) {
                    xPos = (ix-maxCount)*gridStepX;
                    yPos = ((iy-maxCount)*gridStepY)+theBase;
                    zPos = (iz-maxCount)*gridStepZ;

                    if (nodes[iz][iy][ix] == null) {
                        n = new Node(xPos, yPos, zPos);
                        n.minX = -20000;
                        n.maxX = 20000;
                        n.minY = -20000;
                        n.maxY = 20000;
                        n.minZ = -20000;
                        n.maxZ = 20000;
                    }
                    else {
                        n = nodes[iz][iy][ix];
                        n.x = xPos;
                        n.y = yPos;
                        n.z = zPos;
                        n.velocity.x = 0;
                        n.velocity.y = 0;
                        n.velocity.z = 0;
                    }
                    n.damping = nodeDamping;
                    n.scale = nodeScale;
                    n.radius = nodeRadius;
                    n.ramp = nodeRamp;
                    n.maxVelocity = nodeMax;
                    n.midVelocity = nodeMid;
                    nodes[iz][iy][ix] = n;
                    targets[iz][iy][ix] = new PVector(xPos, yPos, zPos);
                    prevYs[iz][iy][ix] = yPos;
                }
            }
        }
    }

    void updateTargets(float dataVal) {
        for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
            for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
                if (ix == maxCount+xCount) {
                    for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
                        if (iy == maxCount+yCount) {
                            targets[iz][iy][ix].y = gridBase;
                        }
                        else if (iy == maxCount-yCount) {
                            targets[iz][iy][ix].y = (0.5*dataVal);
                        }
                        else {
                            targets[iz][iy][ix].y = ((iy-maxCount)*gridStepY)+dataVal;
                        }
                        targets[iz][iy][ix].x = nodes[iz][iy][ix].x;
                        targets[iz][iy][ix].z = nodes[iz][iy][ix].z;
                    }
                }
                else {
                    for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
                        targets[iz][iy][ix].y = prevYs[iz][iy][ix+1];
                        targets[iz][iy][ix].x = nodes[iz][iy][ix].x;
                        targets[iz][iy][ix].z = nodes[iz][iy][ix].z;
                    }
                }
            }
        }
        for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
            for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
                for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
                    nodes[iz][iy][ix].update(targets[iz][iy][ix]);
                    prevYs[iz][iy][ix] = targets[iz][iy][ix].y;
                }
            }
        }
    }

    void drawGrid() {
        //-----------SET PARAMETERS-------------------------
        if (xCount != oldXCount || yCount != oldYCount || zCount != oldZCount) {
            oldXCount = xCount;
            oldYCount = yCount;
            oldZCount = zCount;
        }

        if (nodes[0][0][0].damping != nodeDamping) {
            //updateDamping();
        }
        
        int stepI = 1;
        boolean lineDrawn = false;

        if (drawX && xCount > 0) {
            for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
                for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
                    color c = colors[iy%colors.length];
                    if (c == color(0) && invertBackground) c = color(360);
                    stroke(c, lineAlpha);
                    drawLine(nodes[iz][iy], xCount, drawCurves);
                }
            }
            lineDrawn = true;
        }

        if (drawY && yCount > 0) {
            for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
                for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
                    color c = colors[ix % colors.length];
                    if (c == color(0) && invertBackground) c = color(360);
                    stroke(c, lineAlpha);
                    PVector[] pts = new PVector[maxCount*2+1];
                    int ii = 0;
                    for (int iy = 0; iy < maxCount*2+1; iy++) {
                        pts[ii++] = nodes[iz][iy][ix];
                    }
                    drawLine(pts, yCount, drawCurves);
                }
            }
            lineDrawn = true;
        }

        if (drawZ && zCount > 0) {
            for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
                color c = colors[iy % colors.length];
                if (c == color(0) && invertBackground) c = color(360);
                stroke(c, lineAlpha);
                for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
                    PVector[] pts = new PVector[maxCount*2+1];
                    int ii = 0;
                    for (int iz = 0; iz < maxCount*2+1; iz++) {
                        pts[ii++] = nodes[iz][iy][ix];
                    }
                    drawLine(pts, zCount, drawCurves);
                }
            }
            lineDrawn = true;
        }
    }

    void drawLine(PVector[] points, int len, boolean curves) {
        PVector d1 = new PVector();
        PVector d2 = new PVector();
        float l1,l2, q0,q1,q2;

        int i1 = (points.length-1) / 2-len;
        int i2 = (points.length-1) / 2+len;

        beginShape();
        vertex(points[i1].x, points[i1].y, points[i1].z);
        q0 = 0.5;
        for (int i = i1+1; i <= i2; i++) {
            if (curves) {
                if (i < i2) {
                    l1 = PVector.dist(points[i], points[i-1]);
                    l2 = PVector.dist(points[i], points[i+1]);
                    d2 = PVector.sub(points[i+1], points[i-1]);
                    d2.mult(0.333);
                    q1 = l1 / (l1+l2);
                    q2 = l2 / (l1+l2);
                }
                else {
                    l1 = PVector.dist(points[i], points[i-1]);
                    l2 = 0;
                    d2.set(0,0,0);
                    q1 = l1 / (l1+l2);
                    q2 = 0;
                }
                bezierVertex(points[i-1].x+d1.x*q0, points[i-1].y+d1.y*q0, points[i-1].z+d1.z*q0, 
                points[i].x-d2.x*q1, points[i].y-d2.y*q1, points[i].z-d2.z*q1, 
                points[i].x, points[i].y, points[i].z);
                d1.set(d2);
                q0 = q2;
            }
            else {
                vertex(points[i].x, points[i].y, points[i].z);
            }
        }
        endShape();
    }

    void scaleGrid(float theFactorX, float theFactorY, float theFactorZ) {
        for (int iz = 0; iz < 9; iz++) {
            for (int iy = 0; iy < maxCount*2+1; iy++) {
                for (int ix = 0; ix < maxCount*2+1; ix++) {
                nodes[iz][iy][ix].x *= theFactorX;
                nodes[iz][iy][ix].y *= theFactorY;
                nodes[iz][iy][ix].z *= theFactorZ;
                }
            }
        }
    }
    
    void updateDamping() {
        for (int iz = 0; iz < maxCount*2+1; iz++) {
            for (int iy = 0; iy < maxCount*2+1; iy++) {
                for (int ix = 0; ix < maxCount*2+1; ix++) {
                nodes[iz][iy][ix].damping = nodeDamping;
                }
            }
        }
    }
}