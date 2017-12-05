
from docker import Client
import json

cli = Client(base_url = 'unix:///var/run/docker.sock')

#response = cli.search('nginx')
#for item in response:
#    print item

response = cli.pull('nginx', tag = '1.11', stream = True)
for item in response:
    print "<--%s-->" % item
    #print json.dumps(json.loads(item), indent = 4)

#response = [line for line in cli.push('localhost:5000/registrya', tag = 'latest', stream = True)]
#print response

#image_ids = cli.images('mysql:5.6', quiet = True)
#print cli.tag('0d409d33b27e', 'localhost:5000/nginx')
#import os
#url = 'https://console.cloudin.cn'
#mod = 'api'
#print os.path.join(url, mod)
