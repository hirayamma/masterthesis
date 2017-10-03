import lxml.html
import selenium
import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
from tqdm import tqdm
from time import sleep
import requests
import itertools

# reading
video_id_list=pd.read_csv('videoid.use.csv',encoding="UTF-8")

#combination
video_id_combination = list(itertools.combinations(video_id_list["video_id"],2))
video_id_combination = pd.DataFrame(video_id_combination)
video_id_combination.columns = ['id1','id2']
video_id_combination.to_csv("videoid_combi.csv", index=False)

# # reading
# video_id_combination=pd.read_csv('videoid_combi.csv',encoding="UTF-8")
#
# # scraping
# def func(id1, id2):
#     driver.get("http://www.nicovideo.jp/openlist/" + str(id1) + "+" + str(id2))
#     data = driver.page_source.encode('utf-8')
#     root = BeautifulSoup(data, "html.parser")
#     size = None
#     size = root.find('div',class_="mb8p4").find('p',class_="font12").find('strong').text
#     return id1, id2, size, sleep(1)
#
# # id
# mail = "****"
# password = "*****"
#
# driver = webdriver.Chrome('C:\selenium\chromedriver')
#
# # login
# driver.get("https://account.nicovideo.jp/login")
# driver.find_element_by_id("input__mailtel").send_keys(mail)
# driver.find_element_by_id("input__password").send_keys(password)
# driver.find_element_by_id("login__submit").click()
#
# # crawling
# temp = [[func(id1, id2) for id1, id2 in tqdm(zip(video_id_combination.ix[100000*(x-1):100000*x-1,'id1'],video_id_combination.ix[100000*(x-1):100000*x-1,'id2']))]
#         for x in tqdm(range(1,29))]
# temp = pd.DataFrame(temp)
# print(temp)
# temp.columns = ['id1','id2','commons','delete']
# del temp['delete']
# temp.to_csv("mylistcommons.csv", index=False, encoding='utf-8')
#
# driver.quit()