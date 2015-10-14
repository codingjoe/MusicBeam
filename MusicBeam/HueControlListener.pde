class HueControlListener implements ControlListener {
  public void controlEvent(ControlEvent theEvent) {
    float hue = theEvent.getController().getValue();
    theEvent.getController().setColorActive(color(hue, 100, 100));
    theEvent.getController().setColorForeground(color(hue, 100, 50));
    theEvent.getController().setColorBackground(color(hue, 100, 25));
  }
}