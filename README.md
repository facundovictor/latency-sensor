# latency-sensor

Simple latency sensor, useful for remote wireless links. It parses the latency reported by the ping tool, and if the values exceeds the configured thresholds a mail to the admin will be sent with the html formatted data.

## Requirements:

 * sendmail command (As a MTA or as a MUA with ESMTP).

## How to use it?

 1. git clone https://github.com/facundovictor/latency-sensor.git

 2. chmod 500 sense.awk
 
 3. Edit the ip.conf file. The scripts reads it, and for every line, it parses the following fields (separated by one single space):

  ```<Host description> <IP/FQDN> <Tolerance threshold of packet loss> <Tolerance threshold of average packet latency>```
  
 4. Edit the /etc/crontab file to check it. As an example, let's say we need to check it every 15 minutes:
 
  ``` 0,15,30,45 * * * * root /opt/sense.awk /opt/ip.conf ```

## Example of an output preview:

<h3>Wieless link status (10/01/2016 19:04):</h3>

<p>This mail can be received because of an abnormal latency, or a packet lost. The experiment sample is of <b>20</b> echo requests .</p>
<table border=1>
  <thead>
    <tr>
      <th>Description</th>
      <th>HOST</th>
      <th>IP</th>
      <th>Transmitted</th>
      <th>Received</th>
      <th>Packet Lost</th>
      <th>PL Limit</th>
      <th>Min</th>
      <th>Max</th>
      <th>Average</th>
      <th>Avg Limit</th>
      <th>Deviation</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>AP_street_2_3.3</td>
      <td>192.168.3.3</td>
      <td>192.168.3.3</td>
      <td>20</td>
      <td>0</td>
      <td><b style="color: red;">100%</b></td>
      <td>0%</td>
      <td>&infin; ms</td>
      <td>&infin; ms</td>
      <td><b style="color: red;">&infin; ms</b></td>
      <td>8 ms</td>
      <td>&infin; ms</td>
    </tr>
    <tr>
      <td>AP_street_1_2.2</td>
      <td>192.168.2.2</td>
      <td>192.168.2.2</td>
      <td>20</td>
      <td>16</td>
      <td><b style="color: red;">20%</b></td>
      <td>0%</td>
      <td>1 ms</td>
      <td>3 ms</td>
      <td>2 ms</td>
      <td>8 ms</td>
      <td>&infin; ms</td>
    </tr>
  </tbody>
</table>
