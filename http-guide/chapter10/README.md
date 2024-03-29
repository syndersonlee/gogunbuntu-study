# Chapter 10 HTTP 2.0
## HTTP 2.0 이란?
- 하나의 커넥션 위해 여러 개의 스트림이 동시에 만들어 지는 형태
- 여러 개의 요청과 응답을 동시에 처리하는 것 역시 가능
- 요청과 응답 메시지의 의미를 HTTP/1.1과 같도록 유지

## HTTP 1.1과 2.0의 차이점
- HTTP 명세 프레임이 형태가 상이 함
- 스트림
  - 프레임들의 독립된 양방향 시퀀스
  - 하나의 커넥션에서 여러 개의 스트림이 동시에 열릴 수 있음
  - 스트림 간의 우선순위 설정 가능
- 헤더 압축
  - 압축 콘텍스트를 통해 헤더 압축 가능
- 서버 푸쉬
  - 하나의 요청에 여러 리소스를 응답 받기 가능

## 보안 이슈
- 중재자 캡슐
  - 2.0 -> 1.1로 변환될때 변질 가능성
  - 1.1 -> 2.0은 문제 없음
- 긴 커넥션으로 인한 유출
  - 커넥션이 길면 개인 정보 유출 가능성