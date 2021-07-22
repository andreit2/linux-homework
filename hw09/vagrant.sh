sudo yum install -y git mailx
cd /opt
git clone https://github.com/andreit2/linux-homework.git
cd linux-homework/hw09/
sudo chmod a+x script.sh
sudo echo "00 * * * * root /opt/linux-homework/hw09/script.sh" > /etc/cron.d/0hourly
