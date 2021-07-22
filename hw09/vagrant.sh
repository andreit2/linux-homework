sudo yum install -y git
git clone git@github.com:andreit2/linux-homework.git
cd linux-homework/hw09/
sudo chmod a+x script.sh
sudo echo "00 * * * * root /home/vagrant/linux-homework/hw09/script.sh" > /etc/cron.d/0hourly
