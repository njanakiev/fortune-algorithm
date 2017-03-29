class VEvent implements Comparable<VEvent>{
  // The point at which current event occurs 
  // (top circle point for circle event, focus point for place event)
  PVector point;
  // Whether it is a place event or not
  boolean placeEvent;
  // y coordinate of "point", events are sorted by this "y"
  float y;
  // if "placeEvent", it is an arch above which the event occurs
  VParabola arch;
  
  VEvent(PVector point, boolean placeEvent){
    this.point = point;
    this.placeEvent = placeEvent;
    y = point.y;
    arch = null;
  }
  
  @Override
  int compareTo(VEvent other){
    return (this.y > other.y) ? -1 : 1;
  }
  
  @Override
  String toString(){
    return "VEvent : placeEvent : " + placeEvent + ", y : " + y + ", arch : " + (arch != null);
  }
}