import requests
import os

url = 'https://raw.githubusercontent.com/docker-library/mysql/77f0a50ecd54edafe48ce3a2a328c22e9e7564a8/5.6/Dockerfile'
url = 'https://raw.githubusercontent.com/docker-library/docs/c408469abbac35ad1e4a50a6618836420eb9502e/mysql/logo.png'
filename = os.path.basename(url)

#print "downloading with urllib"
#urllib.urlretrieve(url, "logo.png")
#exit()

#print "downloading with urllib2"
#f = urllib2.urlopen(url)
#data = f.read()
#with open("logo.png", "wb") as code:
#    code.write(data)

print "downloading with requests"
r = requests.get(url)
with open('../' + filename, "wb") as code:
    code.write(r.content)
