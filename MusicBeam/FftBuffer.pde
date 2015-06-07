public class fftBuffer implements AudioBuffer{
  private int size=0;
  private int elems=0;
  private float bufferList[];
  

  
  fftBuffer(int size){
    bufferList = new float[size*fftSize];
    this.size=size;
  }
  AudioBuffer add(AudioBuffer in){
    float temp[] = new float[size*fftSize];
    arrayCopy(bufferList, size, temp, 0, size*(fftSize-1));
    arrayCopy(in.toArray(),0,temp,size*(fftSize-1),size);
    bufferList=temp;
    return this;
  }  
  int size(){
    return bufferList.length;
  }
  float get(int i){
    return bufferList[i];
  }
  float[] toArray(){
    return bufferList;
  }
  float level(){
    float level=0;
    for(int i = 0; i<bufferList.length;i++)
    {
      level+=bufferList[i];
    }
    level/=bufferList.length;
    return level;
  }
}
