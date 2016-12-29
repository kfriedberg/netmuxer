import processing.net.*;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

Server serverProcess;
ConcurrentHashMap<String, Client> targetList;
PrintWriter logFile;

void setup() {
  frameRate(300);
  size(300, 300);
  fill(0);
  textSize(16);
  serverProcess = new Server(this, 4501, "localhost");
  targetList = new ConcurrentHashMap<String, Client>();
  logFile = createWriter("netmuxerLog-" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) 
    + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".log");
}

void draw() {
  background(200);
  int textLines = 1;

  //clean up disconnected targets and pass on
  //messages from connected targets
  for (Map.Entry me : targetList.entrySet()) {
    String target = (String)me.getKey();
    Client targetClient = (Client)me.getValue();
    if (!targetClient.active()) {
      targetList.remove(target);
      writeToLog("Removed connection " + target);
    } else if (targetClient.available() > 0) {
      String message = targetClient.readStringUntil('\n');
      if (message != null) {
        println("In: " + target);
        println(message);
        serverProcess.write(target + "," + message);
      }
    }
  }

  //print active targets
  for (Map.Entry me : targetList.entrySet()) {
    String[] target = split((String)me.getKey(), ',');
    String formattedTarget = "Target IP: " + target[0] + " Port: " + target[1];
    text(formattedTarget, 10, textLines * 16);
    textLines++;
  }

  //receive a command from a source
  Client source = serverProcess.available();
  if (source != null && source.available() > 0) {
    String targetIpRaw = source.readStringUntil(',');
    if (targetIpRaw != null) {
      String targetIp = targetIpRaw.substring(0, targetIpRaw.length()-1);
      String targetPortRaw = source.readStringUntil(',');
      if (targetPortRaw != null) {
        int targetPort = Integer.parseInt(targetPortRaw.substring(0, targetPortRaw.length()-1));
        String targetKey = targetIp + "," + targetPort;
        String targetMessage = source.readStringUntil('\n');
        if (targetMessage != null) {
          Client targetClient = targetList.get(targetKey);
          if (targetClient == null) {
            targetClient = new Client(this, targetIp, targetPort);
            targetList.put(targetKey, targetClient);
            writeToLog("Created connection " + targetKey);
          }
          println("Out: " + targetIp + "," + targetPort);
          println(targetMessage);
          targetClient.write(targetMessage);
        }
      }
    }
  }
  logFile.flush();
}

void writeToLog(String logLine) {
  logFile.println(nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2) + " " 
    + nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2) + " " 
    + logLine);
}