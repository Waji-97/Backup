#!/bin/bash
Info(){

# 3조 banner

echo "   _____                         ____     _____           _       _   "
echo "  / ____|                       |___ \   / ____|         (_)     | |  "
echo " | |  __ _ __ ___  _   _ _ __     __) | | (___   ___ _ __ _ _ __ | |_ "
echo " | | |_ | '__/ _ \| | | | '_ \   |__ <   \___ \ / __| '__| | '_ \| __|"
echo " | |__| | | | (_) | |_| | |_) |  ___) |  ____) | (__| |  | | |_) | |_ "
echo "  \_____|_|  \___/ \__,_| .__/  |____/  |_____/ \___|_|  |_| .__/ \__| "
echo "                        | |                                | |        "
echo "                        |_|                                |_|        "
echo ""
# 지정 함수 사용하여 박스 형태 생성 + 시간 날짜  
banner()
{
  echo "+-----------------------------------------+"
  printf " %-40s \n" "`date`"
  echo "                                         "
  printf "`tput bold` %-40s `tput sgr0`\n" "$@"
  echo "+-----------------------------------------+"
}

# 일반 echo로 텍스트 출력
echo -e "*********************************************"
echo -e "\t시스템 점검 스크립트"
echo -e "*********************************************"
echo -e "  3조 - 건태 - 차노 - 와지 - 도영 - 상훈"
echo -e "*********************************************"
echo ""

# OS 정보 확인 
banner "OS Details"
echo ""
OSName=$(egrep -w "NAME" /etc/os-release|awk -F= '{ print $2 }'|sed 's/"//g')
OSVersion=$(egrep -w "VERSION" /etc/os-release|awk -F= '{ print $2 }'|sed 's/"//g')
printf '\033[33m%-30s :\033[0m %s %s\n' "Operating System" "${OSName}" "${OSVersion}"

printf '\033[33m%-30s :\033[0m %s\n' "Hostname" "$(hostname -f 2> /dev/null || hostname -s)"

printf '\033[33m%-30s :\033[0m %s\n' "Kernel Version" "$(uname -r)"

if [ $(arch | grep x86_64 &> /dev/null) ]; then
  printf '\033[33m%-30s :\033[0m %s\n' "OS Architecture" "64 Bit OS"
else
  printf '\033[33m%-30s :\033[0m %s\n' "OS Architecture" "32 Bit OS"
fi

# CPU 정보 확인
banner "CPU Details"
echo ""
Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
CPU_Arch=$(uname -m)

printf '\033[33m%-30s :\033[0m %s\n' "Physical CPUs" "${Physical_CPUs}"
printf '\033[33m%-30s :\033[0m %s\n' "Virtual CPUs" "${Virt_CPUs}"
printf '\033[33m%-30s :\033[0m %s\n' "CPU Cores" "${CPU_Kernels}"
printf '\033[33m%-30s :\033[0m %s\n' "CPU Model" "${CPU_Type}"
printf '\033[33m%-30s :\033[0m %s\n' "CPU Architecture" "${CPU_Arch}"
printf '\033[33m%-30s :\033[0m %s\n' "CPU Usage Percentage" "${usage}%"

if (( $(echo "$usage < 50" | bc -l) )); then
  echo -e "\033[32mOK!\033[0m"
elif (( $(echo "$usage > 80" | bc -l) )); then
  echo -e "\033[31mDanger!\033[0m"
else
  echo "Usage: $usage%"
fi
echo ""
sleep 1

# Uptime 정보 확인
banner "Uptime"
echo ""
Uptime=$(uptime)
printf '\033[33m%-30s :\033[0m %s\n' "System  Uptime" "${Uptime}"

Uptime_Version=$(uptime -V)
printf '\033[33m%-30s :\033[0m %s\n' "Uptime Version" "${Uptime_Version}"
echo ""
sleep 1

# 커널 파라미터 변 값 제어 시스템 최적화
banner "Kernel Parameters"
echo ""

cp /etc/sysctl.conf /etc/sysctl.conf.bak

printf '\033[33m%-30s\033[0m\n' "Updating sysctl.conf Configuration"

# Increase the maximum number of open file descriptors
echo "fs.file-max = 1000000" >> /etc/sysctl.conf

# Increase the maximum size of shared memory segments
echo "kernel.shmmax = 68719476736" >> /etc/sysctl.conf

# Increase the maximum amount of shared memory available to a single shared memory segment
echo "kernel.shmall = 4294967296" >> /etc/sysctl.conf

# Increase the maximum size of a message queue
echo "kernel.msgmnb = 65536" >> /etc/sysctl.conf

# Increase the maximum size of a message queue
echo "kernel.msgmax = 65536" >> /etc/sysctl.conf

# Increase the maximum size of a semaphore set
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf

# Increase the maximum number of network connections
echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf

# Increase the maximum number of network backlog queue
echo "net.core.netdev_max_backlog = 5000" >> /etc/sysctl.conf

# Increase the maximum number of packets to queue for processing
echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf

# Increase the maximum number of packets to queue for processing
echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf

# Increase the size of the receive buffer used by TCP sockets
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf

# Increase the size of the send buffer used by TCP sockets
echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> /etc/sysctl.conf

# Increase the maximum number of packets to queue for processing
echo "net.ipv4.udp_mem = 65536 131072 262144" >> /etc/sysctl.conf

# Increase the maximum number of packets to queue for processing
echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.conf

# Increase the maximum number of packets to queue for processing
echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.conf

echo ""
printf '\033[32m%-30s\033[0m\n' "Done!"
echo ""

printf '\033[33m%-30s\033[0m\n' "Reloading sysctl.conf Configuration"
echo ""
sysctl -p &> /dev/null
printf '\033[32m%-30s\033[0m\n' "Done!"
echo ""
sleep 1

# 최신 kernel 확인 및 업데이트
latest_kernel=$(yum list updates | grep -E 'kernel\s' | awk '{print $2}' | sort -V | tail -1)
current_kernel=$(uname -r)

if [ -n "$latest_kernel" ] && [ "$latest_kernel" != "$current_kernel" ]; then
  # Update the kernel if it's not on the latest version
  echo "Updating the Kernel..."
  yum -y update kernel > /dev/null 2>&1
elif [ -z "$latest_kernel" ]; then
  # Display a message if there are no packages marked for update
  echo -e "\033[32mYour kernel is up to date!\033[0m"
fi
echo ""
sleep 1

# 최근 서버 shutdown 확인
banner "Recent Server Shutdown"
echo ""
# 최근 서버 shutdown 이유 확인
ShutdownEventsOutput=$(last -x 2> /dev/null | grep -w "shutdown")

if [ -n "$ShutdownEventsOutput" ]; then
  printf '\033[33m%-30s\033[0m\n%s\n' "Most Recent 3 Shutdown Events"

  echo  "$(last -x 2> /dev/null | grep -w "shutdown" | head -3)"

  ShutdownLog=$(grep -w "reboot" /var/log/anaconda/syslog | tail -1)
echo ""
  if [ -n "$ShutdownLog" ]; then
    
    printf '\033[33m%-30s\033[0m\n%s\n' "Cause of Most Recent Shutdown"

    # Display the log
    echo "$ShutdownLog"
  else
    echo "No log found for the cause of the most recent shutdown."
  fi
else
  echo "No shutdown events are recorded."
fi
echo ""
sleep 1

# 최근 시스템 reboot 횟수 확인 및 마지막 reboot 정보
banner "Recent Reboots"
echo ""
reboots=$(last -x | grep reboot | wc -l)
last_reboot=$(last -x | grep reboot | head -1)
printf '\033[33m%-30s\033[0m\n' "Number of recent reboots"
echo ""
echo "${reboots}"
echo ""
printf '\033[33m%-30s\033[0m\n' "Details of last reboot"
echo ""
echo "${last_reboot}"
echo ""
sleep 1

# 최근 서버 접속자 5명 확인
banner "Recent Server Access"
echo ""
RecentAccess=$(last -i | head -n 5)
TimeAccess=$(echo "$RecentAccess" | sort | uniq -c | sort -nr | head -1)
printf '\033[33m%-30s\033[0m\n%s\n' "Recent Server Access" 
echo "${RecentAccess}"
echo ""
printf '\033[33m%-30s\033[0m\n%s\n' "Time with Most Server Access"
echo ""
echo "${TimeAccess}"
echo ""
sleep 1

# 메모리 및 CPU 많이 쓰는 5개 프로세스 확인
banner "5 Most CPU and RAM consumers"
echo ""
CPUProcesses=$(ps aux --sort=-%cpu | awk '{print $11 " " $3 "%"}' | head -6 | tail -5)
printf '\033[33m%-30s\033[0m %s\n' "5 Most CPU Consuming Processes"
echo ""
echo  "${CPUProcesses}"
echo ""
RAMProcesses=$(ps aux --sort=-%mem | awk '{print $11 " " $4 "%"}' | head -6 | tail -5)
printf '\033[33m%-30s\033[0m %s\n' "5 Most RAM Consuming Processes" 
echo ""
echo "${RAMProcesses}"
echo ""
sleep 1

# SWAP memory 정보 확인
banner "SWAP Memory & RAM"
echo ""
SwapMemoryDetails=$(grep -w SwapTotal /proc/meminfo)
TotalSwapMemory_MiB=$(echo $SwapMemoryDetails | awk '{print $2/1024}')
TotalSwapMemory_GiB=$(echo $SwapMemoryDetails | awk '{print $2/1024/1024}')

FreeSwapMemoryDetails=$(grep -w SwapFree /proc/meminfo)
FreeSwapMemory_MiB=$(echo $FreeSwapMemoryDetails | awk '{print $2/1024}')
FreeSwapMemory_GiB=$(echo $FreeSwapMemoryDetails | awk '{print $2/1024/1024}')

printf '\033[33m%-30s :\033[0m %s MiB, %s GiB\n' "Total Swap Memory" "${TotalSwapMemory_MiB}" "${TotalSwapMemory_GiB}"
printf '\033[33m%-30s :\033[0m %s MiB, %s GiB\n' "Free Swap Memory" "${FreeSwapMemory_MiB}" "${FreeSwapMemory_GiB}"

# RAM information 
RAM=$(free -m | awk '/Mem/{printf("%.0f", $3/$2*100)}')

if (( $(echo "$RAM < 50" | bc -l) )); then
echo -e "\033[32mOK!\033[0m"
elif (( $(echo "$RAM > 80" | bc -l) )); then
echo -e "\033[31mDanger!\033[0m"
elif (( $(echo "$RAM > 60" | bc -l) )); then
echo -e "\033[33mCaution!\033[0m"
else
echo "Usage: $RAM%"
fi
echo ""
sleep 1

# 설치된 패키지 업데이트 확인
banner "Installed Pacakges Updates"
echo ""
printf '\033[33m%-30s\033[0m\n' "List of Packages Requiring Updates"
echo ""
Updates=$(yum -q check-update | wc -l)
if [ $Updates == 0 ]; then
printf '\033[32m%s\033[0m\n' "$Updates"
else
printf '\033[31m%s\033[0m\n' "$Updates"
fi
echo ""
sleep 1

# 패키지 자동 업데이트
yum check-update &> /dev/null
if [ $? -eq 100 ]; then
  printf '\033[33m%s\033[0m\n' "Updating packages ..."
  yum update -y &> /dev/null
else
  printf '\033[32m%s\033[0m\n' "Your packages are up to date"
fi

# crontab 작업
banner "Checking & setting up Cronie"
echo ""
script_file="$(readlink -f "$0")"
cron_entry="0 4 * * * $script_file"
temp_file="/tmp/cron.temp"

if ! rpm -qa | grep -q "^cronie\b"; then
  echo "Installing cronie..."
  sudo yum install -y cronie > /dev/null 2>&1
else
  echo "Cronie is already your friend!"
fi

echo "$cron_entry" >> $temp_file

sort $temp_file | uniq | crontab -

rm $temp_file
echo ""
CronieWork=$(crontab -l)
printf '\033[33m%-30s :\033[0m %s\n' "Current Cron Jobs" "${CronieWork}"
echo ""
sleep 1

# Log Rotation
banner "Rotating Logs"
echo ""
/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
printf '\033[32m%-30s\033[0m\n' "Logs rotated successfully!"
echo ""
sleep 1

# Disk 확인과 mount 상태 확인
banner "Disk File & Mount"
echo ""
Dfs=$(fsck -a /dev/sda1)
Cms=$(mount | column -t)
printf '\033[33m%-30s\033[0m\n%s\n\n' "Checking Disk File System"
echo "$Dfs"
echo ""
printf '\033[33m%-30s\033[0m\n%s\n\n' "Checking Mount Status"
echo "$Cms"
echo ""
sleep 1

# Disk 사용량 확인
banner "Disk Usage"
echo ""
printf '\033[33m%-30s\033[0m\n%s\n\n' "Checking Disk Usage"
Diskcheck=$(df -h)
echo "$Diskcheck"
echo ""
sleep 1

# Network 정보 + 상태 확인
banner "Network status + IP address"
echo ""
NetworkStatus=$(ping -q -c 1 -W 1 google.com >/dev/null && echo "The network is up." || echo "The network is down.")
printf '\033[33m%-30s :\033[0m %s\n' "Network Status" "${NetworkStatus}"
IPAddress=$(hostname -I)
printf '\033[33m%-30s :\033[0m %s\n' "IP Address" "${IPAddress}"
echo ""
sleep 1

# 모든 Network 연결 확인
banner "Network Port Connections"
echo ""
ListeningPorts=$(netstat -a)
printf '\033[33m%-30s\033[0m\n' "Network Port Connections"
echo ""
echo "${ListeningPorts}"
echo ""
sleep 1

# 방화벽 확인
banner "Firewall Status & Rules"
echo ""
Fs=$(systemctl status firewalld | head -3)
Fr=$(iptables -L --line | head -7)
printf '\033[33m%-30s\033[0m\n' "Firewall Status"
echo ""
echo "${Fs}"
echo ""
printf '\033[33m%-30s\033[0m\n' "Firewall Rules"
echo ""
echo "${Fr}"
echo ""
sleep 1

# 파일 시스템 확인
banner "File System Status"
echo ""
printf '\033[33m%-30s\033[0m\n%s\n\n' "Checking file system"
FileSys=$(fsck -f /dev/sda1)
printf '\033[31m%-30s\033[0m\n%s\n\n' "${FileSys}"
printf '\033[33m%-30s\033[0m\n%s\n\n' "Confirming file system status"
if [ $? -eq 0 ]; then
	printf '\033[32m%-30s\033[0m\n%s\n\n' "The file system is clean"
else
	printf '\033[31m%-30s\033[0m\n%s\n\n' "The file system is NOT clean"
	exit 1
fi
sleep 1

# /dev 에 device 파일 이외의 것이 존재하고 있는지 확인
banner "Finding parasites in /dev"
echo ""
printf '\033[33m%-30s\033[0m\n%s\n\n' "Checking /dev"
FileList=$(find /dev -type f -exec ls -l {} \; 2>/dev/null)
if [ -z "$FileList" ]; then
printf "\033[32mNo parasites found\033[0m"
else
printf '\033[31m%s\033[0m\n' "${FileList}"
fi
echo ""
sleep 1
}


# 위 함수 실행
Info

Git(){
echo ""
banner "Github upload"
echo ""
# Github upload
if ! command -v curl &> /dev/null
then
    echo "Installing curl..."
    yum install curl -y &> /dev/null
fi

if ! command -v git &> /dev/null
then
    echo "Installing git..."
    yum install git -y &> /dev/null
fi

if [ -z "$(git config --global user.email)" ]
then
    git config --global user.email "wajiwos16@gmail.com" &> /dev/null
fi

if [ -z "$(git config --global user.name)" ]
then
    git config --global user.name "Waji-97" &> /dev/null
fi

EXCLUDE_FILE=$(mktemp)

if [ ! -d "/var/lib/mysql" ]; then
  echo "/var/lib/mysql" >> $EXCLUDE_FILE
fi

if [ ! -d "/etc/ssl/certs" ]; then
  echo "/etc/ssl/certs" >> $EXCLUDE_FILE
fi

if [ ! -d "/etc/ssl/private" ]; then
  echo "/etc/ssl/private" >> $EXCLUDE_FILE
fi

tar -cvpzf /root/backup.tar --exclude-from=$EXCLUDE_FILE /var/www/html /etc/httpd/conf/httpd.conf &> /dev/null

rm $EXCLUDE_FILE


if [ ! -d "/root/Backups" ]
then
    git clone https://Waji-97:<PAT>@github.com/Waji-97/Backups.git /root/Backups &> /dev/null
else
    cd /root/Backups
    git pull origin master &> /dev/null
fi

mv /root/backup.tar /root/Backups/ &> /dev/null

git config --global credential.helper store
echo "https://<PAT>:x-oauth-basic@github.com" > ~/.git-credentials

cd /root/Backups
git add . &> /dev/null
git commit -m "Automated backup $(date +'%Y-%m-%d %H:%M:%S')" &> /dev/null
git push origin master &> /dev/null


printf '\033[32m%-30s\033[0m\n' "Backup file uploaded to Github!"
}

# Git 함수 실행
Git

echo ""
banner "Sending Mail"
echo ""

# Sending mail
for package in postfix cyrus-sasl-plain mailx; do
if ! yum list installed $package &>/dev/null; then
echo "Installing $package..."
yum -y install $package &>/dev/null
fi
done

systemctl restart postfix
systemctl enable postfix

cat >> /etc/postfix/main.cf << EOF
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
EOF

echo "[smtp.gmail.com]:587 <username>:<password>" > /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

systemctl restart postfix

Info  >> result.txt
Git >> result.txt

mail -a result.txt -s "Script results" <receiver-email> <<< "See the attachment for the results"

if [ $? -eq 0 ]; then
    printf '\033[32m%-30s\033[0m\n' "Mail successfully sent!"
else
    printf '\033[31m%-30s\033[0m\n' "Error: Mail not sent."
fi
