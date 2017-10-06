library(jsonlite)
library(dplyr)
library(data.table)

setwd("C:/Data")
load("C:/Data/data.vocaloid.RData")

dt=list()

for (i in 1:2956) {
  message(paste("Process",i,"is runnning..."))
  con <- sprintf("alldata/%04d.jsonl",i)
  temp <- stream_in(file(con))
  dt[[i]] <- data.table(temp)
  }

dt <- rbindlist(dt)
save.image("C:/Data/originaldata.RData")

userid = list()

for (i in 1:16) {
  message(paste("Process",i,"is runnning..."))
  file <- sprintf("userid%02d.csv",i)
  userid[[i]] <- fread(file,header=T,encoding = 'UTF-8')
}

userid <- rbindlist(userid)

dt.v <- left_join(dt.v, userid)

dt.v$upload_time <- as.POSIXct(dt.v$upload_time, origin="1970-1-1")

#再生数推移
##読み込み
ts=list()
for (i in 1:5) {
  message(paste("Process",i,"is runnning..."))
  file <- sprintf("ts%02d.csv",i)
  ts[[i]] <- fread(file, header=F, encoding='UTF-8')
}
ts <- rbindlist(ts)
ts <- ts %>%
  filter(!(V3=="ポイント"))
ts <- ts %>%
  rename(week=V1, rank=V2, point_num=V3, watch_num=V4, comment_num=V5, mylist_num=V6, video_id=V7)
ts[rank=="-",rank:=NA]
ts <- ts %>%
  arrange(video_id, week)
##NAを0に
ts[is.na(ts)] <- 0
##weekの#を外す
ts[,week:=gsub("#","",week)]
ts[,week:=as.integer(week)]
ts <- ts %>% arrange(video_id, week)
##累積にする
ts.sum <- ts[,list(
  week=week,
  rank=rank,
  point_num_sum=cumsum(point_num),
  watch_num_sum=cumsum(watch_num),
  comment_num_sum=cumsum(comment_num),
  mylist_num_sum=cumsum(mylist_num)
  ),
  by=list(video_id)]

# 8期トラックする
video_id <-  ts %>%
  group_by(video_id) %>%
  count %>%
  filter(n>=8)
ts <- left_join(ts, video_id)
ts <- data.table(ts)
ts.use <- ts %>%
  filter(!is.na(n))
ts.use <- data.table(ts.use)
ts.use[,n:=NULL]
# その中で初週から8連続でログがあるもの
# https://qiita.com/stockedge/items/a90e473fe624b979640a
ts.use <- split(ts.use,
                ts.use$video_id)
ts.use.2 = list()
for (df in ts.use) {
  elems <- head(df,8) %>%
    select(rank)
  if (any(elems==0) == FALSE) {
    ts.use.2 <- c(ts.use.2, list(df))
  }
}
ts.use.2 <- rbindlist(ts.use.2)
# 該当する動画のIDを抽出
video_id <- ts.use.2 %>%
  group_by(video_id) %>%
  count
# dt.vとくっつけて、作者が被らない・コミュニティIDがあることを条件に
# 140個ランダムに選ぶ
video_id <- video_id %>%
  sample_n(140,
           replace=TRUE)

# 8期目での数値を取得
video_id.use[,check:=1]
ts.sum <- left_join(ts.sum, video_id.use)
ts.sum <- data.table(ts.sum)
ts.sum.use <- ts.sum %>%
  filter(!is.na(check))
ts.sum.use <- data.table(ts.sum.use)
ts.sum.use[,check:=NULL]

ts.sum.use.split<- split(ts.sum.use,
                ts.sum.use$video_id)
dt.use = list()
for (df in ts.sum.use.split) {
  dt.use <- c(dt.use, list(df[8,]))
}
dt.use <- rbindlist(dt.use)
dt.use <- left_join(dt.use,dt.v)
#ついでに8週までに揃える
ts.sum.use.2 = list()
for (df in ts.sum.use.split) {
   ts.sum.use.2 <- c(ts.sum.use.2, list(df %>% head(8)))
}
ts.sum.use.2 <- rbindlist(ts.sum.use.2)
# クローリングしてきたものをインポート
commons = list()

for (i in 1:195) {
  message(paste("Process",i,"is runnning..."))
  file <- sprintf("openlist/mylistcommons%02d.csv",i)
  commons[[i]] <- fread(file,header=T,encoding = 'UTF-8')
}
#組み合わせを順列に戻す
commons <- rbindlist(commons)
commons2 <- commons[,c(2,1,3)]
colnames(commons2) <- c("id1","id2","commons")
commons <- rbind(commons,commons2)

#ユーザーID欠けているところを埋める
dt.use[video_id=="sm10282629",user_id:="3397653"]
dt.use[video_id=="sm11982230",user_id:="624824"]
dt.use[video_id=="sm12154467",user_id:="1320776"]
dt.use[video_id=="sm12372183",user_id:="1320776"]
dt.use[video_id=="sm12695779",user_id:="2303203"]
dt.use[video_id=="sm12825985",user_id:="2423537"]
dt.use[video_id=="sm12850213",user_id:="811012"]
dt.use[video_id=="sm12894209",user_id:="2423537"]
dt.use[video_id=="sm13136668",user_id:="308936"]
dt.use[video_id=="sm13185918",user_id:="4283869"]
dt.use[video_id=="sm13236011",user_id:="449061"]
dt.use[video_id=="sm13275244",user_id:="865591"]
dt.use[video_id=="so26405782",user_id:="1646151"]

#近接性計算
commons$commons <- as.integer(commons$commons)
commons$commons[is.na(commons$commons)] <- 0
conn <- commons %>%
  group_by(id1) %>%
  summarise(conn=sum(commons))
setnames(conn,"id1","video_id")
dt.use <- left_join(dt.use, conn)
dt.use <- data.table(dt.use)

#community
community <- fread("community_size.csv",encoding='UTF-8')
dt.v <- left_join(dt.v, community)
dt.use <- left_join(dt.use, community)
dt.use <- dt.use %>%
  filter(!is.na(community_id))

#fbshare
fbshare = list()
for (i in 1:4) {
  message(paste("Process",i,"is runnning..."))
  file <- sprintf("fbshare%d.csv",i)
  fbshare[[i]] <- fread(file,header=T,encoding = 'UTF-8')
}
fbshare <- rbindlist(fbshare)
dt.use <- left_join(dt.use,fbshare)

# 見た目に見える品質
ts.use <- data.table(dt.use)
dt.use[,mylist_per:=mylist_num_sum/watch_num_sum]

# 作者の性質
# その前に何本動画出したか
dt.use[,past_movies:=0]
for (i in 1:nrow(dt.use)) {
  df <- dt.v %>%
    filter(user_id==as.character(dt.use[i,"user_id"])) %>%
    filter(upload_time < as.integer(dt.use[i,"upload_time"]))
  dt.use[i,past_movies:=nrow(df)]
}
# 動画の再生数平均
dt.use[,ave_watch_num:=0]
for (i in 1:nrow(dt.use)) {
  hoge <- dt.v %>%
    filter(user_id==as.character(dt.use[i,"user_id"])) %>%
    filter(upload_time < as.integer(dt.use[i,"upload_time"])) %>%
    summarise(watch_num_ave=mean(watch_num))
  dt.use[i,ave_watch_num:=as.integer(hoge$watch_num_ave)]
}

# mylist
openlistsize = list()
for (i in 1:140) {
  message(paste("Process",i,"is runnning..."))
  file <- sprintf("avesubsize/openlist%02d.csv",i)
  openlistsize[[i]] <- fread(file,sep=",",encoding = 'UTF-8',na.strings=c("NA",""))
}
openlistsize <- rbindlist(openlistsize,fill=TRUE)
openlistsize$mylists <- gsub(".*… ","",openlistsize$mylists)
openlistsize$mylists <- gsub("件","",openlistsize$mylists)
openlistsize$mylists <- as.integer(openlistsize$mylists)


#use
analysis_table <- dt.use %>%
  select(video_id,community_size,conn,past_movies,ave_watch_num,fbshares)

#ts use
ts.sum.use.2 <- left_join(ts.sum.use.2,
                          dt.use %>% select(video_id,title))
ts.sum.use.2 <- ts.sum.use.2 %>%
  filter(!is.na(title))
ts.sum.use.2 <- data.table(ts.sum.use.2)
ts.sum.use.2[,mylist_per:=mylist_num_sum/watch_num_sum]