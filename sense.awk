#/usr/bin/awk -f

# The scripts reads the ip.conf file, and for every line, it parses the follow-
# ing fields (separated by one single space):
#     <Host description>
#     <IP/FQDN>
#     <Tolerance threshold of packet loss>,
#     <Tolerance threshold of average packet latency>

BEGIN {

# Configurable variable definitions -------------------------------------------
# Destination mail
    mail_destination="sysop@bblanca.com.ar"
# Amount of echo requests
    attempts=20
# Seconds elapsed between every echo request
    interval=1

# Initialization --------------------------------------------------------------
# Calculate the date and time in 'dd/mm/yyyy hh:mm' format.
    date_command="date \"+%d/%m/%Y %H:%M\""
    date_command | getline date_time
    close(date_command)

# Mail content initialization. The mail will be sent only on abnormal values.
    send_email=0
    output="From: ABNORMAL LATENCY <"mail_destination">\n"
    output=output"Subject: ABNORMAL latency / packet LOST - "date_time" \n"
    output=output"Content-type: text/html\n\n"
    output=output"<h3>Wieless link status ("date_time"):</h3>\n\n"
    output=output"<p>This mail can be received because of an abnormal latency,\
 or a packet lost. The experiment sample is of <b>"attempts"</b> echo requests\
 .</p>"
    output=output"<table border=1><thead><tr><th>Description</th><th>HOST</th>\
    <th>IP</th><th>Transmitted</th><th>Received</th><th>Packet Lost</th>\
    <th>PL Limit</th><th>Min</th><th>Max</th><th>Average</th>\
    <th>Avg Limit</th><th>Deviation</th></tr></thead><tbody>"
}

# ITERATION -------------------------------------------------------------------
{
# Every executed ping will output like the following:
#
# 10 packets transmitted, 10 received, 0% packet loss, time 8999ms
# rtt min/avg/max/mdev = 0.035/0.046/0.083/0.015 ms

    exec_command="ping -c "attempts" -i "interval" "$2
    while (( exec_command | getline line) > 0) {
        split(line,results,",")
        if (results[1] ~ /transmitted$/){
            split(results[1],amount_T," ")
            transmitted=amount_T[1]
        }
        if (results[2] ~ /received$/){
            split(results[2],amount_R," ")
            received=amount_R[1]
        }
        if (results[3] ~ /packet loss$/){
            split(results[3],amount_PL," ")
            lost=substr(amount_PL[1],0,length(amount_PL[1]) - 1)
        }

        if (line ~ /^rtt/){
            rtt=substr(line,24)
            split(rtt,statistics,"/")
# min/avg/max/mdev
            min=statistics[1]
            avg=statistics[2]
            max=statistics[3]
            mdev=statistics[4]
        }
        if (line ~ /^PING/){
            split(line,data," ")
            host=substr(data[3],2,length(data[3]) - 2)
        } 
    }
    close(exec_command)

    output=output"<tr><td>"$1"</td><td>"$2"</td><td>"host"</td><td>"transmitted"</td><td>"received"</td>"
    if (lost > $3){
        send_email=1
        output=output"<td><b style=\"color: red;\">"lost"%</b></td>"
    } else {
        output=output"<td>"lost"%</td>"
    }
    
    output=output"<td>"$3"%</td><td>"min" ms</td><td>"max" ms</td>"

    
    if (avg > $4){
        send_email=1
        output=output"<td><b style=\"color: red;\">"avg" ms</b></td>"
    } else {
        output=output"<td>"avg" ms</td>"
    }
    output=output"<td>"$4" ms</td><td>"mdev"</td></tr>"

}
END {
    output=output"</tbody></table>"
        if (send_email){
#           print output
            system("echo '"output"' | sendmail "mail_destination)
        }
}
