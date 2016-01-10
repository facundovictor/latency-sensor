#/usr/bin/awk -f

# El script lee el archivo de configuracion de ips, donde cada linea significa:
# <Descripcion del host>, <IP/FQDN del host>, <Umbral de tolerancia de perdida de paquetes>, <Umbral de tolerancia de promedio de latencia>

BEGIN {
# mail destino
	maildestino="sysop@bblanca.com.ar"
# Cantidad de echo request
	intentos=20
# Segundos entre cada echo request
	intervalo=1

#       Se calcula la fecha y tiempo en formato dd/mm/yyyy hh:mm
        date_command="date \"+%d/%m/%Y %H:%M\""
        date_command | getline fecha
        close(date_command)

#       Se comienza a armar el mail segun los valores obtenidos. El mail solo se envia en caso de valores anormales.
	enviarmail=0
        salida="From: ABNORMAL LATENCY <"maildestino">\n"
        salida=salida"Subject: Latencia ANORMAL / PERDIDA de paquetes - "fecha" \n"
        salida=salida"Content-type: text/html\n\n"
        salida=salida"<h3>Estado de enlaces ("fecha"):</h3>\n\n"
	salida=salida"<p>Este mail puede ser enviado por una latencia anormal, o por perdida de paquetes. La muestra es de <b>"intentos"</b> echo requests.</p>"

	salida=salida"<table border=1><thead><tr><th>Descripcion</th><th>HOST</th><th>IP</th><th>Transmitted</th><th>Received</th><th>Packet Lost</th><th>PL Limit</th><th>Min</th><th>Max</th><th>Average</th><th>Avg Limit</th><th>Deviation</th></tr></thead><tbody>"
}
{
#10 packets transmitted, 10 received, 0% packet loss, time 8999ms
#rtt min/avg/max/mdev = 0.035/0.046/0.083/0.015 ms
	comando="ping -c "intentos" -i "intervalo" "$2
	while (( comando | getline linea) > 0) {
		split(linea,resultados,",")
		if (resultados[1] ~ /transmitted$/){
			split(resultados[1],cantidadT," ")
			transmitidos=cantidadT[1]
		}
		if (resultados[2] ~ /received$/){
			split(resultados[2],cantidadR," ")
			recibidos=cantidadR[1]
		}
		if (resultados[3] ~ /packet loss$/){
			split(resultados[3],cantidadPL," ")
			perdidos=substr(cantidadPL[1],0,length(cantidadPL[1]) - 1)
		}

		if (linea ~ /^rtt/){
			rtt=substr(linea,24)
			split(rtt,estadisticas,"/")
# min/avg/max/mdev
			min=estadisticas[1]
			avg=estadisticas[2]
			max=estadisticas[3]
			mdev=estadisticas[4]
		}
		if (linea ~ /^PING/){
			split(linea,datos," ")
			host=substr(datos[3],2,length(datos[3]) - 2)
		} 
	}
	close(comando)

	salida=salida"<tr><td>"$1"</td><td>"$2"</td><td>"host"</td><td>"transmitidos"</td><td>"recibidos"</td>"
	if (perdidos > $3){
		enviarmail=1
		salida=salida"<td><b style=\"color: red;\">"perdidos"%</b></td>"
	} else {
		salida=salida"<td>"perdidos"%</td>"
	}
	
	salida=salida"<td>"$3"%</td><td>"min" ms</td><td>"max" ms</td>"

	
	if (avg > $4){
		enviarmail=1
		salida=salida"<td><b style=\"color: red;\">"avg" ms</b></td>"
	} else {
		salida=salida"<td>"avg" ms</td>"
	}
	salida=salida"<td>"$4" ms</td><td>"mdev"</td></tr>"

}
END {
	salida=salida"</tbody></table>"
        if (enviarmail){
#		print salida
                system("echo '"salida"' | sendmail "maildestino)
        }
}
