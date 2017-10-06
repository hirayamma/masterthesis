import pandas as pd
from tqdm import tqdm
from time import sleep
import requests
import lxml.html
from urllib.request import build_opener, HTTPCookieProcessor
from urllib.parse import urlencode, parse_qs
from http.cookiejar import CookieJar
from bs4 import BeautifulSoup
from selenium import webdriver
import yaml

# reading
video_id_list=pd.read_csv('openmylists.csv',encoding="UTF-8")

# rooping
def roop(x):
    print("プロセス%dが進行中"%x)
    video_id = video_id_list.ix[x,"video_id"]
    temp = [func(video_id, i) for i in tqdm(range(video_id_list.ix[x,'start'],video_id_list.ix[x,'end']+1))]
    temp = [x for y in temp for x in y]
    temp = pd.DataFrame(temp)
    temp.columns = ['mylists']
    temp['video_id'] = video_id
    temp.to_csv("avesubsize2/openlist%02d.csv" %x, index=False, encoding='utf-8')

# scraping
def func(video_id, i):
    driver.get("http://www.nicovideo.jp/openlist/" + str(video_id) + "?page=" + str(i))
    data = driver.page_source.encode('utf-8')
    root = BeautifulSoup(data, "html.parser")
    elems = root.find_all("td", width="100%")
    mylists = [elem.find("strong").text for elem in elems]
    sleep(5)
    return mylists


# id
account = open('account.yml',"r+")
account = yaml.load(account)
mail = account["mail"]
password = account["password"]

driver = webdriver.Chrome('C:\selenium\chromedriver')

# login
driver.get("https://account.nicovideo.jp/login")
driver.find_element_by_id("input__mailtel").send_keys(mail)
driver.find_element_by_id("input__password").send_keys(password)
driver.find_element_by_id("login__submit").click()

# crawling
for x in range(26,len(video_id_list)):
    roop(x)

driver.quit()