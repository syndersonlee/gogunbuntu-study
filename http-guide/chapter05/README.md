# Chapter 05 웹 서버

## Perl 웹 서버 실습
- Perl 설치 : [홈페이지](https://www.perl.org/get.html) 참고
  UNIX/MacOS 는 Perl이 기본으로 설치되어 있음 (`perl -v` 명령어로 확인)
- `perl type-o-serve.pl [PORT_NUMBER]`로 프로그램 실행 후 브라우저에서 `http://localhost:[PORT_NUMBER]/` 호출

- 터미널을 통해 HTTP Request 확인
```
 <<<Request From 'localhost'>>>
GET /favicon.ico HTTP/1.1
Host: localhost:8080
Connection: keep-alive
sec-ch-ua: "Google Chrome";v="105", "Not)A;Brand";v="8", "Chromium";v="105"
sec-ch-ua-mobile: ?0
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36
sec-ch-ua-platform: "macOS"
Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8
Sec-Fetch-Site: same-origin
Sec-Fetch-Mode: no-cors
Sec-Fetch-Dest: image
Referer: http://localhost:8080/
Accept-Encoding: gzip, deflate, br
Accept-Language: en,ko-KR;q=0.9,ko;q=0.8,en-US;q=0.7

 <<<Type Response Followed by '.'>>>
```

- 터미널을 통해 HTTP Reponse 작성
```
HTTP/1.1 200 OK
Connection: close
Content-type: text/plain

Hi There! Welcome to Web Server Sample
.
```
![스크린샷 2022-09-15 23 58 43](https://user-images.githubusercontent.com/49651099/190437832-87c12335-b7cb-4743-8cc4-1edb86c81966.png)

