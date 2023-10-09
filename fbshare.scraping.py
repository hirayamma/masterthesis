import requests
from lxml import etree
import pandas as pd
import time
from tqdm import tqdm
import json

dat=pd.read_csv('videoid.use.csv',encoding="UTF-8")
variables = open('variables.json')
variables = json.load(variables)

url_fb = "http://graph.facebook.com/?id="
url_nico = "http://www.nicovideo.jp/watch/"
access_token = variables['access_token']

#クローリング・スクレイピングの関数
def func(video_id):
    url = url_fb + url_nico + str(video_id) + "&" + access_token
    resp = requests.get(url)
    dict = json.loads(resp.text)
    fbshares = None
    if dict is not None:
        fbshares = format(dict['share']['share_count'])
    return video_id, fbshares

for i in range(2,5):
    temp = [func(video_id) for video_id in tqdm(dat.ix[35*(i-1):35*i-1,'video_id'])]
    temp = pd.DataFrame(temp)
    temp.columns = ['video_id','fbshares']
    temp.to_csv("fbshare%d.csv" %i, index=False, encoding='utf-8')
    time.sleep(3600)
    #API制限回避のため