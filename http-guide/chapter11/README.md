# Chapter 11 클라이언트 식별과 쿠키
클라이언트 식별 기술들을 알아보자

## 개별 접촉
- 개별 인사
  - 특화 환경 및 메시지 생성
- 저장된 사용자 정보
  - 신용카드 정보나 비밀번호 정보 저장
- 세션 추적
  - HTTP 트랜잭션 식별

## 클라이언트 IP 주소
- IP주소 저장
## 사용자 로그인
- 모두 다 아는 그 로그인
## 뚱뚱한 로그인
- URL 내부에 사용자의 식별값을 넣어 전달
  - 단점
    - URL이 너무 길다
    - 타인에게 공유하지 못하는 URL
    - 캐시 사용 불가
    - 세션간 지속 불가
## 쿠키

### 쿠키의 종류
- 세션 쿠키
- 지속 쿠키

### 쿠키 동작 방식
- id 값을 쿠키에 저장

### 쿠키 상자
- 기본적인 발상은 서버 관련 정보를 저장하고 그 정보를 서버에 접근 할때마다 요청하는 방식

### 쿠키와 세션 추적
- 세션 쿠키를 이용해서 사용자를 추적

### 쿠키, 보안 그리고 개인정보
- 기타 개인 정보에만 유의한다면, 편리함이 더 큼
- 지속 쿠키를 사용해서 사용자 추적 하는 케이스가 bad case