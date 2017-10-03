import requests
from lxml import etree
import pandas as pd
import time
from tqdm import tqdm

dat=pd.read_csv('userid.csv',encoding="UTF-8")

video_id=[]
user_id=[]

for i in range(7,34):
    for page in tqdm(dat.ix[10000*(i-1):10000*i-1,"video_id"]): 
        xml = requests.get("http://ext.nicovideo.jp/api/getthumbinfo/" + str(page))
        root = fromstring(xml.content)
        video_id.append(str(page))
        uid = root.find(".//user_id")
        if uid is None:
            user_id.append(None)
        else:
            user_id.append(root.find(".//user_id").text)
    df = pd.DataFrame({"video_id":video_id, "user_id":user_id})
    df.to_csv("userid%02d.csv" %i, index=False, encoding='utf-8')