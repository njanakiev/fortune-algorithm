import java.util.HashSet;
import java.util.PriorityQueue;

class Voronoi {
  boolean done;

  // The root of the tree, that represents a beachline sequence
  VParabola root;
  // Width and Height of the diagram
  float w, h;
  // Current "y" position of the line (see Fortune's algorithm)
  float ly;
  // Container of places with which we work
  ArrayList<PVector> places;
  // Container of edges which will be teh result
  ArrayList<VEdge> edges;
  // Set of deleted (false) Events
  HashSet<VEvent> deleted;
  // List of all new points that were created during the algorithm
  ArrayList<PVector> points;
  // Priority queue with events to process
  PriorityQueue<VEvent> queue;

  Voronoi(ArrayList<PVector> vertices, int w, int h) {
    done = false;
    root = null;
    places = vertices;
    this.w = w;
    this.h = h;

    points  = new ArrayList<PVector>();
    deleted = new HashSet<VEvent>();
    queue   = new PriorityQueue<VEvent>();
    edges   = new ArrayList<VEdge>();
    for (PVector vertex : vertices) {
      queue.add(new VEvent(vertex, true));
    }
  }

  ArrayList<VEdge> getEdges() {
    while (!queue.isEmpty()) {
      VEvent event = queue.poll();
      ly = event.point.y;
      println(event);
      if (deleted.contains(event)) {
        deleted.remove(event);
      } else if (event.placeEvent) {
        insertParabola(event.point);
      } else {
        removeParabola(event);
      }
    }
    finishEdge(root);

    for (VEdge edge : edges) {
      if (edge.neighbour != null) {
        edge.start = edge.neighbour.end;
        edge.neighbour = null;
      }
    }
    return edges;
  }

  void update() {
    if (!done) {
      if (!queue.isEmpty()) {
        VEvent event = queue.poll();
        ly = event.point.y;
        if (deleted.contains(event)) {
          deleted.remove(event);
        } else if (event.placeEvent) {
          insertParabola(event.point);
        } else {
          removeParabola(event);
        }
        finishEdge(root);
      } else { 
        done = true; 
        finishEdge(root);

        for (VEdge edge : edges) {
          if (edge.neighbour != null) {
            edge.start = edge.neighbour.end;
            edge.neighbour = null;
          }
        }
      }
    }
  }

  void draw(boolean showDelaunay) {
    for (VEdge edge : edges) {
      stroke(200);
      PVector p0 = edge.start, p1 = edge.end;
      if (edge.neighbour != null) {
        p0 = edge.neighbour.end;
      }
      line(p0.x, p0.y, p1.x, p1.y);
      
      // Delaunay Triangulation
      if(showDelaunay){
        stroke(0, 0, 255);
        line(edge.left.x, edge.left.y, edge.right.x, edge.right.y);
      }
    }
    stroke(200, 255, 200);
    line(0, ly, width, ly);
    stroke(0, 255, 0);
    drawBeachline();

    noStroke();
    fill(255);
    for (PVector p : places) { 
      ellipse(p.x, p.y, 6, 6);
    }
  }

  void drawBeachline() {
    Float prevX = 0.0, prevY = Float.NaN;
    VParabola par = getParabolaByX(prevX);
    if (par.site != null) {
      prevY = getY(par.site, prevX);
    }
    int n = 1000;
    for (int i=1; i<n; i++) {
      Float x = w * (float) i / (float) n, y = Float.NaN;
      par = getParabolaByX(x);
      if (par.site != null) { 
        y = getY(par.site, x);
      } else { 
        println(par);
      }
      if (!prevY.isNaN() && !y.isNaN()) { 
        line(prevX, prevY, x, y);
      }
      prevX = x; 
      prevY = y;
    }
  }

  // Processing the place event
  void insertParabola(PVector p) {
    if (root == null) {
      root = new VParabola(p); 
      return;
    }

    if (root.isLeaf && root.site.y - p.y < 1) // degenerate event - both points at the same height
    {
      PVector fp = root.site;
      root.isLeaf = false;
      root.setLeft( new VParabola(fp) );
      root.setRight(new VParabola(p)  );
      PVector s = new PVector((p.x + fp.x)/2, height); // start edge
      points.add(s);
      if (p.x > fp.x) root.edge = new VEdge(s, fp, p); // decide between left and right
      else root.edge = new VEdge(s, p, fp);
      edges.add(root.edge);
      return;
    }

    VParabola par = getParabolaByX(p.x);

    if (par.circleEvent != null)
    {
      deleted.add(par.circleEvent);
      par.circleEvent = null;
    }

    PVector start = new PVector(p.x, getY(par.site, p.x));
    points.add(start);

    VEdge edgeLeft = new VEdge(start, par.site, p);
    VEdge edgeRight = new VEdge(start, p, par.site);

    edgeLeft.neighbour = edgeRight;
    edges.add(edgeLeft);

    par.edge = edgeRight;
    par.isLeaf = false;

    VParabola p0 = new VParabola(par.site);
    VParabola p1 = new VParabola(p);
    VParabola p2 = new VParabola(par.site);

    par.setRight(p2);
    par.setLeft(new VParabola());
    par.left().edge = edgeLeft;

    par.left().setLeft(p0);
    par.left().setRight(p1);

    checkCircle(p0);
    checkCircle(p2);
  }

  // Processing the circle event
  void removeParabola(VEvent e) {
    VParabola p1 = e.arch;

    VParabola xl = getLeftParent(p1);
    VParabola xr = getRightParent(p1);

    VParabola p0 = getLeftChild(xl);
    VParabola p2 = getRightChild(xr);

    if (p0 == p2) {
      println("ERROR, parabola left and right have the same focus");
    }

    if (p0.circleEvent != null) { 
      deleted.add(p0.circleEvent); 
      p0.circleEvent = null;
    }
    if (p2.circleEvent != null) { 
      deleted.add(p2.circleEvent); 
      p2.circleEvent = null;
    }

    PVector p = new PVector(e.point.x, getY(p1.site, e.point.x));
    points.add(p);

    xl.edge.end = p;
    xr.edge.end = p;

    //VParabola higher;
    VParabola higher = new VParabola();
    VParabola par = p1;
    while (par != root)
    {
      par = par.parent;
      if (par == xl) higher = xl;
      if (par == xr) higher = xr;
    }
    higher.edge = new VEdge(p, p0.site, p2.site);
    edges.add(higher.edge);

    VParabola gparent = p1.parent.parent;
    if (p1.parent.left() == p1)
    {
      if (gparent.left()  == p1.parent) gparent.setLeft ( p1.parent.right() );
      if (gparent.right() == p1.parent) gparent.setRight( p1.parent.right() );
    } else
    {
      if (gparent.left()  == p1.parent) gparent.setLeft ( p1.parent.left()  );
      if (gparent.right() == p1.parent) gparent.setRight( p1.parent.left()  );
    }

    checkCircle(p0);
    checkCircle(p2);
  }

  // Recursively finishes all infinite edges in the tree
  void finishEdge(VParabola n) {
    if (n.isLeaf) {
      return;
    }
    float mx;
    if (n.edge.direction.x > 0.0)	mx = max(width, 	n.edge.start.x + 10);
    else							mx = min(0.0, 		n.edge.start.x - 10);

    PVector end = new PVector(mx, mx * n.edge.f + n.edge.g); 
    n.edge.end = end;
    points.add(end);

    finishEdge(n.left() );
    finishEdge(n.right());
  }

  // Returns the current x position of an intersection point
  float getXOfEdge(VParabola par, float y) {
    VParabola left = getLeftChild(par);
    VParabola right= getRightChild(par);

    PVector p = left.site;
    PVector r = right.site;

    float dp = 2.0 * (p.y - y);
    float a1 = 1.0 / dp;
    float b1 = -2.0 * p.x / dp;
    float c1 = y + dp / 4 + p.x * p.x / dp;

    dp = 2.0 * (r.y - y);
    float a2 = 1.0 / dp;
    float b2 = -2.0 * r.x/dp;
    float c2 = ly + dp / 4 + r.x * r.x / dp;

    float a = a1 - a2;
    float b = b1 - b2;
    float c = c1 - c2;

    float disc = b*b - 4 * a * c;
    float x1 = (-b + sqrt(disc)) / (2*a);
    float x2 = (-b - sqrt(disc)) / (2*a);

    float ry;
    if (p.y < r.y ) ry =  max(x1, x2);
    else ry = min(x1, x2);

    return ry;
  }

  // Returns the Parabola that is under this "x" position in
  VParabola getParabolaByX(float x) {
    VParabola par = root;
    float xNew = 0.0;

    while (!par.isLeaf) {
      xNew = getXOfEdge(par, ly);
      if (xNew > x) par = par.left();
      else par = par.right();
    }
    return par;
  }

  float getY(PVector p, float x) { // focus point, x-coordinates
    float dp = 2 * (p.y - ly);
    float a1 = 1 / dp;
    float b1 = -2 * p.x / dp;
    float c1 = ly + dp / 4 + p.x * p.x / dp;

    return (a1*x*x + b1*x + c1);
  }

  // Checks the circle event (disappearing) of this parabola
  void checkCircle(VParabola par) {
    VParabola leftParent = getLeftParent (par);
    VParabola rightParent = getRightParent(par);

    VParabola a  = getLeftChild (leftParent);
    VParabola c  = getRightChild(rightParent);

    if (a == null || c == null || a.site == c.site) return;

    PVector s = null;
    s = getEdgeIntersection(leftParent.edge, rightParent.edge);
    if (s == null) return;

    float dx = a.site.x - s.x;
    float dy = a.site.y - s.y;

    float d = sqrt( (dx * dx) + (dy * dy) );

    if (s.y - d >= ly) { 
      return;
    }

    VEvent event = new VEvent(new PVector(s.x, s.y - d), false);
    points.add(event.point);
    par.circleEvent = event;
    event.arch = par;
    queue.add(event);
  }

  PVector getEdgeIntersection(VEdge a, VEdge b) {
    float x = (b.g - a.g) / (a.f - b.f);
    float y = a.f * x + a.g;

    if ((x - a.start.x)/a.direction.x < 0) return null;
    if ((y - a.start.y)/a.direction.y < 0) return null;

    if ((x - b.start.x)/b.direction.x < 0) return null;
    if ((y - b.start.y)/b.direction.y < 0) return null;	

    PVector p = new PVector(x, y);		
    points.add(p);
    return p;
  }
}