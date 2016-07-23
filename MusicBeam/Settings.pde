Button loadDefaultSettingsButton, loadSettingsButton, saveSettingsButton;
import controlP5.*;
import java.util.Hashtable;
import java.util.Set;

Hashtable<String, int[]> uiAlignments = new Hashtable<String, int[]>(); 

void initSettings()
{
  saveSliderLabelAlign();
  cp5.getProperties().setFormat(ControlP5.SERIALIZED);
  
  loadDefaultSettingsButton = cp5.addButton("loadDefaultSettings").setSize(129, 45).setPosition(10, 515);
  loadDefaultSettingsButton.getCaptionLabel().set("Default Settings").align(ControlP5.CENTER, ControlP5.CENTER);
  
  loadSettingsButton = cp5.addButton("loadSettings").setSize(129, 45).setPosition(143, 515);
  loadSettingsButton.getCaptionLabel().set("Load Settings").align(ControlP5.CENTER, ControlP5.CENTER);
  
  saveSettingsButton = cp5.addButton("saveSettings").setSize(129, 45).setPosition(276, 515);
  saveSettingsButton.getCaptionLabel().set("Save Settings").align(ControlP5.CENTER, ControlP5.CENTER);
}

public void loadDefaultSettings()
{
  cp5.loadProperties("default.musicbeam");
  resetSliderLabelAlign();
}

public void loadSettings()
{
  selectInput("Load Music Beam settings", "selectedSettingsFile");
}

public void saveSettings()
{
  selectOutput("Save Music Beam settings:", "saveSettingsFile");
}

void selectedSettingsFile(File selection) 
{
  if (selection != null) {
    cp5.loadProperties(selection.getAbsolutePath());
    resetSliderLabelAlign();
  }
}

void saveSettingsFile(File selection) 
{
  if (selection != null) {
    String path = selection.getAbsolutePath();
    if(!path.contains(".musicbeam.ser"))
      path+= ".musicbeam";
      
    cp5.saveProperties(path);
  }
}

/*
 * This is a necessary fix for cp5
 * Currently after using cp5.loadProperties all slider alignments are breaking
 *
 * This function stores all alignments on app initialization
 */
void saveSliderLabelAlign() 
{
  for(Slider s:cp5.getAll(Slider.class)) {
    uiAlignments.put(s.getName(), s.getCaptionLabel().getAlign());
  }
}

/*
 * This is a necessary fix for cp5
 * Currently after using cp5.loadProperties all slider alignments are breaking
 *
 * This function reloads all label alignments (taken from saveSliderLabelAlign())
 */
void resetSliderLabelAlign() 
{
  Set<String> keys = uiAlignments.keySet();
  for(String key: keys){
    int[] alignments = uiAlignments.get(key);
    cp5.getController(key).getCaptionLabel().align(alignments[0], alignments[1]);
  }
}