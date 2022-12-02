# Chapter 12 기본 인증
인증 모듈

## 인증 포로토콜 및 헤더
기본 인증 및 다이제스트 인증 프로토콜 존재
    
1. 인증 요청    
    - GET 방식
    - 인증 정보 X

2. 인증 요구
    - 인증 요구 및 401 반화

3. 인증
    - Authorization 헤더에 이름과 비밀번호 기술

4. 인증 정보 확인
    - OK 회신

## 기본 인증

### Base64 인코딩
- 8바이트 시퀀스를 6바이트 시퀀스로 변경

### Proxy 인증
- 본 서버가 아닌 Proxy 서버를 통해 인증

### 문제점

1. 사실상 Base64 인코딩은 비밀번호 그대로 보는 것과 다르지 않음
2. 해당 내용 그대로 전달해서 서버 접근 가능
3. 가짜 서버의 위장에 취약
