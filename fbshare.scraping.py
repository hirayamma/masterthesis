import requests
from lxml import etree
import pandas as pd
import time
from tqdm import tqdm
import json

dat=pd.read_csv('videoid.use.csv',encoding="UTF-8")

url_fb = "http://graph.facebook.com/?id="
url_nico = "http://www.nicovideo.jp/watch/"
access_token = "518673188484136|hfYe6mCu_Mquo9CrdeFz3XIHpWo"

#クローリング・スクレイピングの関数
def func(video_id):
    url = url_fb + url_nico + str(video_id) + "&" + access_token
    resp = requests.get(url)
    dict = json.loads(resp.text)
    print(dict)
    fbshares = None
    if dict is not None:
        fbshares = format(dict['share']['share_count'])
        print(fbshares)
    return video_id, fbshares

temp = [func(video_id) for video_id in tqdm(dat['video_id'])]
temp = pd.DataFrame(temp)
temp.columns = ['video_id','fbshares']
temp.to_csv("fbshare.csv", index=False, encoding='utf-8')