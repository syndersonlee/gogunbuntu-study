# ch8 쿼리 성능 최적화

## 쿼리가 느린 이유는 무엇일까요?

- 쿼리는 응답 시간이 중요
    - 쿼리 라이프 사이에서 CPU, 네트워크, 통계, 계획, 잠금에 시간 소비
    - 

## 느린 쿼리 기본 : 데이터 액세스 최적화

### 데이터베이스에 불필요한 데이터를 요청하고 있습니까?
### MySQL이 너무 많은 데이터를 검사하고 있습니까?

## 쿼리를 재구성하는 방법

### 복잡한 쿼리 대 많은 쿼리
### 쿼리 자르기
### 조인 분해

## 쿼리 실행 기본 사항

### MySQL 클라이언트/서버 프로토콜
### 쿼리 상태
### 쿼리 최적화 프로세스
### 쿼리 실행 엔진
### 클라이언트에게 결과 반환하기

## MySQL 쿼리 옵티마이저의 한계

### UNION 제한 사항
### 동등 전파
### 병렬 실행
### 동일한 테이블에 대한 SELECT와 UPDATE

## 특정 유형의 쿼리 최적화

### COUNT() 쿼리 최적화
### 조인 쿼리 최적화
### ROLLUP으로 GROUP BY 최적화
### LIMIT 및 OFFSET 최적화
### SQL_CALC_FOUND_ROWS 최적화
### UNION 최적화