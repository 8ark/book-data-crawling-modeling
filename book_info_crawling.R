rm(list=ls())

library(rvest)
library(lubridate)
library(stringr)
library(tibble)
library(dplyr)

# max page chk

tar <- "http://www.yes24.com/24/Category/Display/001001019001001?PageNumber=1"


# 내가 보려는 카테고리의 최대 페이지 수 파악

max_page <- function(tar_url){
  read_html(tar_url) %>%
    html_nodes("div.yesUI_pagenS .num") %>%
    html_text() %>%
    as.numeric() %>%
    max() %>%
    return()
}

max_page(tar)


  # 주소 만드는 과정


max <- max_page(tar)
root <-"http://www.yes24.com"

i <-1
j <-1

book <- c()
idx <-c(T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F,T,F)

### 카테고리 파악
## 경제경영: 001001025
##사회 비평: 001001022
##소설/시/희곡: 001001046
##에세이: 001001047
##여행: 001001009
##역사: 001001010
##예술: 001001007
##인문: 001001019
##자기계발: 001001026
##자연과학: 001001002
## 잡지: 001001024


for (i in 1:max) {
  
  tar_url <- paste0("http://www.yes24.com/24/Category/Display/001001019001001?PageNumber=",i)
  print(tar_url)
  read_html(tar_url) %>%
    html_nodes("div.goods_name a") %>%
    html_attr("href") ->  link_list
  link_list <- link_list[idx]
  
  for (j in 1:length(link_list)){
    print(tar)
    tar <- paste0(root, link_list[j])
    books <- read_html(tar)  # 파이프 연산자를 여러 번 요청하면 오류가 난다. 한 번만 한 후, 여러 번 활용
    
    books %>%
      html_nodes(".gd_name") %>%
      html_text() %>%
      .[1] -> title
    
    books %>%
      html_nodes("tr:nth-child(1) .yes_m") %>%
      html_text() -> pr
      str_replace(pr, "원","") %>%
      .[1]  -> price

    books %>%
      html_nodes(".gd_pub a") %>%
      html_text() -> publisher
    
    books %>%
      html_nodes(".gd_auth a") %>%
      html_text() %>%
      .[1]-> writer

    books %>%
      html_nodes("td.txt.lastCol") %>%
      html_text() %>%
      .[1] %>%
      ymd()-> time
    
    books %>%
      html_nodes("td.txt.lastCol") %>%
      html_text() %>%
      .[2] ->pwc

    unlist(str_extract_all(pwc, "[0-9]+쪽")) ->pg
    str_replace(pg, "쪽","") -> page

    unlist(str_extract_all(pwc, "[0-9]+g")) -> wg
      if(length(wg) > 0) {
        str_replace(wg, "g","") %>%
          as.numeric()-> weight
      } else{
        as.numeric(0) -> weight
      }
    
    unlist(str_extract_all(pwc, "[*+a-zA-Z0-9]+mm")) ->length

    unlist(str_extract(length, "[0-9]+[*]")) -> hz
    str_replace(hz, "[[:punct:]]", "") -> horizon
    
    unlist(str_extract(length, "[*]+[0-9]+[*]")) -> vt
    str_replace(vt, "[[:punct:]]", "") -> v
    str_replace(v, "[[:punct:]]", "") -> vertical
    
    unlist(str_extract(length, "[0-9]+mm")) -> ht
    str_replace(ht, "[a-z]+", "") -> height
    
    books %>%
      html_nodes("#infoset_specific .lastCol") %>%
      html_text() %>%
      .[3] -> isbn13
    
    books %>%
      html_nodes("#infoset_specific .lastCol") %>%
      html_text() %>%
      .[4] -> isbn10

    
    ttal <- tibble(title, price, writer, publisher, time, page, weight, horizon, vertical, height, isbn13, isbn10)
    book %>%
      bind_rows(ttal) -> book
  }  
  
}

book %>% distinct(title)
readr::write_excel_csv(book, "book_category.csv")