class VEdge{
  PVector left, right, start, end;
  PVector direction;
  VEdge neighbour;
  float f, g;
  boolean intersected, iCounted;
  
  VEdge(PVector s, PVector a, PVector b){
	start		= s;
	left		= a;
	right		= b;
	neighbour	= null;
	end			= null;

	f = (b.x - a.x) / (a.y - b.y) ;
	g = s.y - f * s.x ;
	direction = new PVector(b.y - a.y, -(b.x - a.x));
  }
  
  @Override
  String toString(){
    return "VEdge : " + start + ", " + end 
         + ", intersected : " + intersected 
         + ", iCounted : " + iCounted 
         + ", f : " + f + ", g : " + g
         + ", neighbour : " + (neighbour != null);
  }
}