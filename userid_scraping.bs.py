import lxml.html
import selenium
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd
import time
from tqdm import tqdm
#import csv

dat=pd.read_csv('userid.csv',encoding="UTF-8")

video_id=[]
user_id=[]

driver = webdriver.Chrome('C:\selenium\chromedriver')

for i in range(7,34):
    for page in tqdm(dat.ix[10000*(i-1):10000*i-1,"video_id"]): 
        driver.get("http://ext.nicovideo.jp/api/getthumbinfo/" + str(page))
        data = driver.page_source.encode('utf-8')
        soup = BeautifulSoup(data, "lxml-xml")
        video_id.append(str(page))
        if soup.find("user_id"):
            user_id.append(soup.find("user_id").string)
        else:
            user_id.append(None)
    df = pd.DataFrame({"video_id":video_id, "user_id":user_id})
    
    df.to_csv("userid%02d.csv" %i, index=False, encoding='utf-8')
    
driver.quit()