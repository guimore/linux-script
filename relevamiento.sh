#!/bin/bash

# Asegurarse de ejecutar como root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Este script debe ejecutarse como root (sudo)."
  exit 1
fi

OUTPUT="relevamiento_$(hostname)_$(date +%Y%m%d).txt"

echo "==================================================" | tee "$OUTPUT"
echo " RELEVAMIENTO DE INFRAESTRUCTURA - $(hostname)" | tee -a "$OUTPUT"
echo " Fecha: $(date)" | tee -a "$OUTPUT"
echo "==================================================" | tee -a "$OUTPUT"

echo -e "\n[+] 1. INFORMACIÓN DEL SISTEMA OPERATIVO Y KERNEL" | tee -a "$OUTPUT"
cat /etc/os-release | tee -a "$OUTPUT"
uname -r | tee -a "$OUTPUT"

echo -e "\n[+] 2. HARDWARE: CPU Y MEMORIA RAM" | tee -a "$OUTPUT"
echo "--- CPU ---" | tee -a "$OUTPUT"
lscpu | grep -E "Model name|Socket\(s\)|Core\(s\) per socket|CPU\(s\):" | tee -a "$OUTPUT"
echo "--- RAM ---" | tee -a "$OUTPUT"
free -h | tee -a "$OUTPUT"

echo -e "\n[+] 3. ALMACENAMIENTO Y PARTICIONES (Discos y LVM)" | tee -a "$OUTPUT"
lsblk | tee -a "$OUTPUT"
echo "--- Uso de Discos (df -h) ---" | tee -a "$OUTPUT"
df -h | grep -v tmpfs | tee -a "$OUTPUT"

echo -e "\n[+] 4. CONFIGURACIÓN DE RED" | tee -a "$OUTPUT"
ip -c a | tee -a "$OUTPUT"
echo "--- Rutas (Gateway) ---" | tee -a "$OUTPUT"
ip route | tee -a "$OUTPUT"

echo -e "\n[+] 5. SERVICIOS ACTIVOS (Systemd habilitados)" | tee -a "$OUTPUT"
systemctl list-unit-files --type=service --state=enabled | tee -a "$OUTPUT"

echo -e "\n[+] 6. PUERTOS EN ESCUCHA (Servicios corriendo)" | tee -a "$OUTPUT"
ss -tulpn | tee -a "$OUTPUT"

echo -e "\n[+] 7. PAQUETES INSTALADOS (Principales / RPM o DEB)" | tee -a "$OUTPUT"
if command -v dpkg &> /dev/null; then
    dpkg -l | grep "^ii" | awk '{print $2 " " $3}' | tee -a "$OUTPUT"
elif command -v rpm &> /dev/null; then
    rpm -qa --qf "%{NAME} %{VERSION}-%{RELEASE}\n" | tee -a "$OUTPUT"
fi

echo -e "\n==================================================" | tee -a "$OUTPUT"
echo " Relevamiento completado. Guardado en: $OUTPUT"
echo "=================================================="