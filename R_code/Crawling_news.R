
# 시작에 앞서 필요한 패키지가 2개 있습니다.

install.packages("rvest")   # html 을 이용하기 위한 패키지입니다.
install.packages("stringr") # 문장을 단어로 끊어주기 위해 필요한 패키지입니다.

library(rvest)
library(stringr)

# 그 다음에 필요한 건
# 저희가 크롤링한 데이터를 담을 그릇을 만드는 겁니다.

title <- c()
press <- c()
time <- c()
body <- c()
url <- c()

# 그 다음에는 저희가 크롤링하고 싶은 페이지를 값에 집어넣습니다.

url_crawl <- "https://media.daum.net/breakingnews/digital"


# 그 다음으로 selectorGadget을 통해 알게 된 코드를 입력합니다.
# 확장 프로그램 설치

# 여러 개를 눌러서 담습니다. 저희가 이번에 담은 내용은
# title에 넣겠습니다.
t_css = "#mArticle .tit_thumb .link_txt"

# 다음으로 프레스와 시간을 넣으려고 하는데
# 프레스와 시간은 붙어 있습니다.
# 먼저 데이터를 담아오고 나중에 데이터를 분리하겠습니다.

pt_css = ".info_news"

# 바디도 저장을 합니다.
bd_css = ".desc_thumb .link_txt"


#그리고 read_html이라는 입력어를 사용할 겁니다.
# read_html은 저희가 웹사이트에서 f12를 눌렀을 때 나오는 html 쿼리를
# 다 읽는 겁니다.

#저희는 저희가 보려고 하는 웹사이트를 넣겠습니다.

hdoc = read_html(url_crawl)


# 그리고 이 html 문서에서 저희가 추출한 css 노드를 볼 겁니다.

# html_node 와 html_nodes의 차이는 selectorGadget으로 
# 하나를 눌렀냐, 두개를 눌렀냐로 갈립니다.
t_node = html_nodes(hdoc, t_css)
pt_node = html_nodes(hdoc, pt_css)
bd_node = html_nodes(hdoc, bd_css)
bd_node

# 이 노드를 실행하면 우리가 우클릭으로 검사를 누르면 나오는 그 html 코드가
# 그대로 나오죠.

# 저희는 이 부분에서 텍스트만 보고 싶어요.
# 그걸 위해 저희는 html_text를 이용합니다.
# html_text 는 < > 와 같은 부분을 다 제외합니다.

html_text(t_node)

# 이거를 title_part 라는 변수에 넣어줄게요.

title_part = html_text(t_node)
title_part

# 그럼 단어만 볼 수 있죠???

# 이런 것처럼 다른 것들도 적용할게요.

pt_part = html_text(pt_node)
bd_part = html_text(bd_node)


# pt_part 를 한 번 볼게요
pt_part

# pt_part 는 다른 내용들이랑 다르게
# 언론사 정보랑 시간 정보가 같이 있죠??
# 이제 이걸 쪼개줄 겁니다당

# string 중에서 필요한 부분만 뽑아 쓰는 게 str_sub 라는 명령어입니다.

# str_sub(이용할 value, 얼마나 잘라 쓸거냐)
time_part = str_sub(pt_part, -5)

# 어?!?! 그런데 언론사는 이름이 다 달라요.
# 어디서 끊어야 할지...흠
# str_sub의 다른 기능을 써야 합니다.

# str_sub(pt_part, start =, end = ) 잘라먹는 파트에 start랑 end 를 넣을 수 있어요.
# start 는 어디서부터 가져갈 건지, end는 어디까지 갖고 올 건지

# 우리가 쓸 언론사 정보는 앞에서부터니까 start는 필요없을 것 같고요.

press_part = str_sub(pt_part, end = -9)
press_part


# 하...이제 바디만 남았습니다...

bd_part

# 바디를 보면 \n 처럼 쓸데없는 애들이 있죠.
# 얘네 다 칠 겁니다.

# gsub 라는 명령어를 쓴다고 하네요
# gsub("어떤 거","어떻게",밸류 넣고)

body_part = gsub("\n", " ", bd_part)

# 이제는 공백을 없앨 겁니다...
# 거...거의...다...

# 공백을 없애는 명령어는 str_trim 이라는 앱니다.
# str_trim(밸류, side = "both") 앞뒤 공백을 모두 없애고 싶을 때
# str_trim(밸류, side = "left") 앞 공백만 없애고 싶으면
# str_trim(밸류, side = "right") 뒷 공백만 없애고 싶으면

body_part2 = str_trim(body_part, side = "both")


# 마지막 (진짜 마지막)

t_node
# 보시면 이 안에 url 이 있는 걸 보실 수 있죠

# 여기서 html_text를 사용하면 저희가 필요한 꺽쇠가 사라집니다.
# 이번엔 반대로 html_attr을 사용합니다.
# html_attr은 태그에 대해서 가지고 오는 앱니다.

# href, class 모두 attr 이에요. 

# url 을 먼저 봐야 하니까 href 를 통해 url을 담을게요

url_part = html_attr(t_node,"href")

title <- c(title, title_part)
press <- c(press, press_part)
time = c(time, time_part)
body = c(body, body_part2)
url = c(url, url_part)

title
# 어 title에도 '\'이 있네요
# 이것도 지울게요

title_part = gsub("\\W", " ", title_part)

title_part = str_trim(title_part, side = "both")
title_part

# 다시 할게요
title <- c(title, title_part)


# 다 끝났습니다... 이렇게 저장한 정보를 table로 묶을게요

# cbind를 사용하면 matrix로 형성할게요

news = cbind(title, press, time, body, url)
news

# 데이터를 테이블 형태로 볼게요
View(news)


# 다 끝났네요.
# 이제 크롤링에 대한 기본은 다 배웠습니다.

# 그런데...
# 저희가 지금 우리가 본 페이지만 크롤링하려는 게 아니라
# 많은 데이터를 끌어다 쓸거 잖아요?
# for문을 사용하겠습니다.
# 두둥!!

# for문은 반복문이라고 해요
# for문을 쓰면 내가 끝내라고 할 때까지 자동으로 데이터를 끌어옵니다.

for (x in vector) {
  
}

for (x in 0:5) { # x라는 임의의 값을 넣고, 얘
  #를 몇 번 돌릴 건지 봅니다.
  x <- x+1       # 한 번 들어갈 때마다 x값이 어떻게 변하는 건지를 넣는 거에요
  
  print(x)       # print는 출력함수라고, 저희가 알고 있는 값을 보여주는 앱니다.
}                # x 가 0부터 시작해서 저 루프를 5가 될 때까지 하는 겁니다.


# 저희 사이트를 보니까 총 6페이지네요.


# 일단 txt로 저희가 여태 한 코드를 보여드릴게요 [미래의 나야...얼른 해라]

# 메모장에서 url_base = "링크를 넣습니다. 페이지를 누르면 페이지 관련 url이 보이죠"
# https://media.daum.net/breakingnews/digital?page=6
# 위 예시처럼 page=숫자가 있습니다.

# for문을 이용해서 자동으로 이 페이지가 넘어가서도 코드를 수행할 수 있도록 할게요.


# 실행을 위해서 모든 데이터를 지우겠습니다.

rm(list=ls())

library(rvest)
library(stringr)

title = c()
press = c()
time = c()
body = c()
url = c()

url_base = "https://media.daum.net/breakingnews/digital?page="
# [여기 여기]
# [여기를 시작으로 페이지 숫자를 자동으로 변환시킬 거에요.]
# [그럼 페이지가 계속 변하면서 같은 활동을 하겠죠?]

for(i in 1:21)
{
  
  # paste는 떨어져 있는 value 들을 붙여주는 앱니다.
  # paste(붙일 애1, 붙일 애2, sep = "")
  # sep 는 붙일 거 사이에 넣을 거 있니? 하는 겁니다.
  # 저희는 아무 것도 없어야 하니까 공백을 넣겠습니다.
  
  url_crawl = paste(url_base,i, sep="")
  
  t_css = "#mArticle .tit_thumb .link_txt"
  pt_css = ".info_news"
  bd_css = ".desc_thumb .link_txt"
  
  hdoc = read_html(url_crawl)
  
  t_node = html_nodes(hdoc, t_css)
  pt_node = html_nodes(hdoc, pt_css)
  bd_node = html_nodes(hdoc, bd_css)
  
  title_part = html_text(t_node)
  pt_part = html_text(pt_node)
  bd_part = html_text(bd_node)
  time_part = str_sub(pt_part, -5)
  title_part = gsub("\\W", " ", title_part)
  title_part = str_trim(title_part, side = "both")
  press_part = str_sub(pt_part, end = -9)
  body_part = gsub("\n", "", bd_part)
  body_part2 = str_trim(body_part, side = "both")
  url_part = html_attr(t_node,"href")
  
  url_part = html_attr(t_node,"href")
  title =c(title, title_part)
  press = c(press, press_part)
  time = c(time, time_part)
  body = c(body, body_part2)
  url = c(url, url_part)
}
news = cbind(title, press, time, body, url)


# 그리고 view로 다시 보시면

View(news)


# 그리고 마지막으로 저장을 해야 하니까
# write.csv(변수 이름, "어디에\\저장할 이름.확장자")
write.csv(news,"C:\\Users\\ycg00\\Desktop\\R 데이터 분석\\crawltest.csv")

# 한글이 깨지시는 분이 있을 거 같아요.
# 그런 분들은
# 1. csv 파일을 메모장으로 부르고
# 2. 다른 이름으로 저장에서 유니코드로 형식을 설정하고
# 3. 확장자 csv로 하고 저장
# 4. 하면 됩니다.

# 진짜 끝. 수고하셨습니다.
