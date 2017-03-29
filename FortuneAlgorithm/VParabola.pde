class VParabola{
  VEvent circleEvent;
  VParabola leftParabola, rightParabola, parent;
  boolean isLeaf;
  PVector site;
  VEdge edge;
  
  VParabola(){
    this.site = null;
    leftParabola = null;
    rightParabola = null;
    parent = null;
    edge = null;
    circleEvent = null;
    isLeaf = false;
  }
  
  VParabola(PVector site){
    this.site = site;
    leftParabola = null;
    rightParabola = null;
    parent = null;
    edge = null;
    circleEvent = null;
    isLeaf = true;
  }
  
  VParabola left(){ return leftParabola; }
  VParabola right(){ return rightParabola; }
  
  void setLeft(VParabola p){
    leftParabola = p;
    p.parent = this;
  }
  void setRight(VParabola p){
    rightParabola = p;
    p.parent = this;
  }
  
  @Override
  String toString(){
    return "VParabola : circleEvent : " + (circleEvent != null) 
         + ", leftParabola : " + (leftParabola != null)
         + ", rightParabola : " + (rightParabola != null)
         + ", parent : " + (parent != null)
         + ", isLeaf : " + isLeaf
         + ", edge : " + (edge != null);
  }
}

// Returns the closest left leave of the tree
VParabola getLeft(VParabola p){ return getLeftChild(getLeftParent(p)); }
// Returns the closest right leafe of the tree
VParabola getRight(VParabola p){ return getRightChild(getRightParent(p)); }

// Returns the closest parent which is on the left
VParabola getLeftParent  (VParabola p){
  VParabola par    = p.parent;
  VParabola pLast  = p;
  while(par.left() == pLast) 
  { 
    if(par.parent == null) return null;
    pLast = par; 
    par = par.parent; 
  }
  return par;
}
// Returns the closest parent which is on the right
VParabola getRightParent  (VParabola p){
  VParabola par    = p.parent;
  VParabola pLast  = p;
  while(par.right() == pLast) 
  { 
    if(par.parent == null) return null;
    pLast = par; par = par.parent; 
  }
  return par;
}

// Returns the closest leave which is on the left of current node
VParabola getLeftChild    (VParabola p){
  if(p == null) return null;
  VParabola par = p.left();
  while(!par.isLeaf) par = par.right();
  return par;
}
// Returns the closest leave which is on the right of current node
VParabola getRightChild  (VParabola p){
  if(p == null) return null;
  VParabola par = p.right();
  while(!par.isLeaf) par = par.left();
  return par;
}