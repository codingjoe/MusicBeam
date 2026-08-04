import java.net.DatagramSocket;
import java.net.DatagramPacket;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicInteger;

// Art-Net (DMX over Ethernet) effect selection.
// Reads a single DMX channel; its value selects the active effect by index
// (0 = Blackout / no effect, 1..N = the other effects). Opt-in via the
// "Art-Net (DMX)" toggle. Uses only the JDK, no extra libraries.

static final byte[] ART_NET_ID    = "Art-Net\0".getBytes();
static final int ART_NET_OP_DMX   = 0x5000; // ArtDMX opcode
static final int ART_NET_DMX_DATA = 18;     // offset of the DMX data in an ArtDMX packet
static final int ART_NET_PORT     = 6454;  // Art-Net standard UDP port
static final int ART_NET_UNIVERSE = 0;     // 15-bit universe to listen on
static final int ART_NET_CHANNEL  = 1;     // 1-indexed DMX channel = effect index

ArtNet artNet;

class ArtNet implements Runnable
{
  final AtomicInteger pending = new AtomicInteger(Integer.MIN_VALUE);
  volatile boolean running = false;
  int lastValue = -1;  // edge-trigger; only touched by the receive thread
  DatagramSocket socket;

  // Called from controlEvent() on the animation thread. Idempotent.
  void setEnabled(boolean on)
  {
    if (on && !running) {
      try {
        socket = new DatagramSocket(ART_NET_PORT);
        running = true;
        lastValue = -1;  // re-arm so the current console value is applied
        new Thread(this).start();
        println("Art-Net listening on UDP " + ART_NET_PORT + ", universe " + ART_NET_UNIVERSE + ", channel " + ART_NET_CHANNEL);
      }
      catch (Exception e) {
        println("Art-Net failed to start: " + e.getMessage());
        running = false;
        socket = null;
      }
    } else if (!on && running) {
      running = false;
      if (socket != null)
        socket.close();
      socket = null;
    }
  }

  // Receive loop; runs on its own thread and never touches ControlP5.
  void run()
  {
    byte[] buf = new byte[530];  // 18 byte header + up to 512 DMX channels
    DatagramPacket pkt = new DatagramPacket(buf, buf.length);
    while (running) {
      try {
        pkt.setLength(buf.length);  // receive() shrinks length; reset so large packets aren't truncated
        socket.receive(pkt);
        parse(pkt.getData(), pkt.getLength());
      }
      catch (Exception e) {
        if (running)
          println("Art-Net receive error: " + e.getMessage());
      }
    }
  }

  // Read the selected channel of an ArtDMX packet and hand its value to the
  // animation thread. Anything else is ignored.
  void parse(byte[] b, int len)
  {
    int i = ART_NET_DMX_DATA + ART_NET_CHANNEL - 1;
    if (len > i
      && Arrays.equals(b, 0, ART_NET_ID.length, ART_NET_ID, 0, ART_NET_ID.length)
      && le16(b, 8) == ART_NET_OP_DMX
      && (le16(b, 14) & 0x7fff) == ART_NET_UNIVERSE)
    {
      int value = b[i] & 0xff;
      if (value != lastValue) {  // edge-trigger so the GUI stays usable between changes
        lastValue = value;
        pending.set(value);
      }
    }
  }

  // 16 bit little-endian read.
  int le16(byte[] b, int i)
  {
    return (b[i] & 0xff) | ((b[i+1] & 0xff) << 8);
  }

  // Called once per frame from draw(); the only place ControlP5 is touched.
  void update()
  {
    int v = pending.getAndSet(Integer.MIN_VALUE);
    if (v >= 0 && v < effectArray.length)
      effectArray[v].activate();
  }
}
