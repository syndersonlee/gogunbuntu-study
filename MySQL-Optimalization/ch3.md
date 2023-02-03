# ch3 성능 스키마

## 성능 스키마 소개

- 성능 스키마가 어떻게 작동하는 지 소개해야 하는 두 가지 개념
    - 인스트루먼트
        - 정보를 얻고자 하는 MySQL 코드의 어떤 부분
    - 컨슈머
        - 어떤 코드가 수행되었는 지에 대한 정보 저장하는 테이블

- 실 사용 시
    1. performance_schema는 호출을 매크로로 캡슐화 진행
    2. 컨슈머 테이블에 결과 기록

### 인스트루먼트 요소

```
1. statement/sql/select
2. wait/synch/mutex/innodb/autoinc_mutex
```
- 가장 왼쪽은 인스트루먼트의 종류
    - statement : sql문
    - wait : 대기문
- 따라서 1번은 select문 / 2번은 mutex에 정의하는 autoincrement인 것을 알 수 있음

### 컨슈머 체계

- 컨슈머는 인스트루먼트가 정보를 보내는 대상
- 약 110개의 테이블 존재

#### 현재 및 과거 데이터

이벤트 이름 별 특징
- *_current : 현재 서버 이벤트
- *_history : 스레드당 10개의 완료 이벤트
- *_history_long : 전역 스레드당 최종 10,000개의 완료 이벤트
- events_waits : 뮤텍스 획득과 같은 로우-레벨 서버 대기
- event_statement : SQL 문
- events_stages : 임시 테이블 생성이나 데이터 전송 프로파일 정보
- events_transactions : 트랜잭션 정보

#### 요약 테이블과 다이제스트

- 요약 테이블은 요약 된 정보 저장
    - ex) memory_by_thread_event_name : 스레드 당 메모리 사용량

#### 인스턴스

- 설치에 사용할 수 있는 객체 인스턴스
- file_instances : 엑세스 한 스레드 수

#### 셋업

- 런타임 설정에 사용

### 자원 소비

- 데이터는 메모리에 보관
- 컨슈머는 최대 사이즈 설정 가능 - 메모리 제한
- 인스트루먼트 비활성화와 관계 없이 메모리 할당 해제 X
- 더 많은 인스트루먼트 수행 -> CPU 활성화

### 제약 사항

- performance schema의 제약 사항

| MySQL 컴포넌트 지원 | 특정 Instrument와 consumer 활성화 필요 | 메모리 해제 어려움 | 
| -- | -- | -- |
| 스토리지 엔진이 memory instrument를 지원하지 않는 경우 파악이 어려움 | InnoDB 버퍼 풀이나 전역 버퍼 활성화가 없을 시 데이터 수집 X | 서버 재시작이 없을 시 메모리 해제가 어려움 |

### sys 스키마

- MySQL 5.7부터 `perforamance_schema` 데이터에 대한 동반 스키마 포함
- 해당 스키마는 `view`와 `stored prosedure routine`으로만 구성
- 자체 데이터 저장 X

### 스레드 이해하기

- MySQL 서버는 멀티 스레드 방식 소프트웨어
- 각 스레드는 최소 두 개의 고유 식별자 존재
    - 운영 체제 ID 스레드
    - MySQL 스레드
        - `performance_schema` 내에서 `THREAD_ID`라 명명
        - 포그라운드에 뜨는 `PROCESSLIST_ID`와는 다름
- 잠금을 해제할 때는 thread table내에서 `PROCESSLIST_ID`를 조회

## 설정

- 성능 스키마의 인스트루먼트나 컨슈머를 동적으로 활성화하거나 비활성화

### 성능 스키마의 활성화와 비활성화

- `performance_schema` 변수를 설정하여 성능 스키마 활성화 가능

### 인스트루먼트 활성화와 비활성화

- `performance_schema` 인스트루먼트를 활성화 하거나 비활성화하는 세 가지 옵션
    - `setup_instrument` 테이블 사용
    - `sys` 스키마에서 `ps_setup_enable_instrument` 스토어드 프로시저 호출
    - 서버 시작 때 `performance_schema_instrument` 파라미터 사용

#### Update 문

- Update 문을 사용하여 SQL 문 인스트루먼트 활성화
- 다만 서버 재시작시 다시 설정 필요

#### sys 스토어드 프로시저

- `ps_setup_enable_instrument` 및 `ps_setup_disable_instrument` 사용
- 서버 재시작 시 다시 설정 필요

#### 시작 옵션

- `perforamnce_schema_instrument`를 사용해서 옵션 저장
- 내부에 ON/OFF를 지정하여 활성화 및 비활성화

### 컨슈머 활성화와 비활성화

- `setup consumers` 테이블 업데이트
- 스토어드 프로시저 사용
- 파라미터 설정

약 15개의 컨슈머 존재 : 책 참고

### 특정 객체에 대한 모니터링 튜닝

- 특정 객체 모니터링 가능
- `OBJECT TYPE` 열 특징
    - EVENT
    - FUNCTION
    - PROCEDURE
    - TABLE
    - TRIGGER
- 오브젝트 타입, 스키마, 네임, 활성화 유무를 설정 하여 검사 가능
- INSERT 문을 SQL 문 처리하고 `init_file`옵션을 사용해서 SQL 파일 업로드

### 스레드 모니터링 튜닝

- `setup_threads` 테이블에는 백그라운드 스레드 목록 포함
    - `Enable`열은 인스트루먼트 활성화 여부 지정
    - `HISTORY`열은 과거 이력 여부 저장 지정
- 다만 사용자 스레드 설정은 미저장
    - `setup_actors`에 저장
- 위 정보 또한 `init_file`을 사용하여 로드

### 성능 스키마에 대한 메모리 크기 조정

- `PERFORMANCE_SCHEMA` 엔진을 사용하는 테이블에 데이터 저장
- 메모리에 저장되고 크기 조정이 자동적으로 처리

### 기본값

- 성능 값은 기본적으로 활성
- 인스트루먼트는 비활성화
- 전역, 스레드 구문 및 트랜잭션 인스트루먼트만 활성
- 대부분 자동 크기 조절
- _history 테이블은 마지막 10개 저장
- _history_long 테이블은 최신 10000개

## 성능 스키마 사용

- 성능 스키마 사용 방법

### SQL 문 점검

- 성능 하락을 일으키는 쿼리와 그 이유를 알 수 있음

#### 일반 SQL 문

- `events_statement_current`, `events_statements_history`, `events_history_long 테이블에 구문 메트릭스 저장

#### performance_schema 직접 사용

- 인덱스를 사용하지 않는 모든 쿼리의 경우 NO_INDEXED_USED > 0 OR NO_GOOD_INDEX_USED를 실행
- 임시 테이블을 생성한 모든 쿼리의 경우 CREATED_TMP_TABLES > O OR CREATED_TMP_DISK_TABLES > 0

#### sys 스키마 이용

- 오류와 경고를 반환한 모든 구문 제공

#### 프리페어드 스테이트먼트

- 통계 데이터 총합 제공
- 인스트루먼트 활성화 필요

#### 스토어드 루틴

- 오류 핸들러가 호출되었는 지 정보 검색 가능
- 계측이 필요시 특정 패턴의 인스트루먼트 활성화 필요
- 잘못된 값이 들어왔을 때 반환 값 자체는 변경되지 않지만 오래 걸리거나 표시가 다름

#### 구문 프로파일링

- 쿼리 내에서 오래 걸린 단계에 대한 답을 찾을 수 있음
- 프로파일링의 경우 일반적인 서버 단계에서만 사용

### 읽기 대 쓰기 성능 점검

- 워크 로드 상에서 대부분의 업무가 쓰기 인지 읽기 인지 확인 가능
- 대기 시간 또는 행의 바이트 확인 가능

### 메타데이터 잠금 점검

- DB 객체 정의가 변경되지 않도록 보호
- 트랜잭션이 완료될 때까지 유지
- `performance_schema`와 `metadata_locks` 테이블은 DDL 요청을 허용하지 않는 지 쉽게 식별 가능

### 메모리 사용량 점검

- MySQL 내부에서 정확히 메모리를 어떻게 사용하는지 세부 정보 확인 가능

#### performance_schema를 직접 사용

- `memory_summary_` 접두사를 사용하는 다이제스트 테이블에 저장

#### sys 스키마 사용

- `sys.memory_global_total` 뷰는 메모리 총량 제공

### 변수 점검

- 성능 스키마를 다양한 계측을 새로운 수준으로 보여줌
- 계측 변수
    - 서버 변수 
        - 전역
        - 세션
        - 소스
    - 상세 변수
        - 전역
        - 세션
        - 집계
            - 호스트
            - 사용자
            - 계정
            - 스레드
        - 사용자 변수
- 전역 변수 값은 global_variables 테이블에 저장
- 세션 변수는 session_variables 테이블에 저장
- 활용
    - 활성화된 세션과 다른 세션 변수
    - 스레드 기준 집결
        - 리소스 사용 감지 가능
    - 서버 시작 이후 동적으로 변경된 모든 변수

### 자주 발생하는 오류 점검

- `performance_schema`에서 전역 오류 별로 오류를 집계하는 다이제스트 테이블 제공
- 가장 많이 오류 발생하는 쿼리 발견 가능

### 성능 스키마 자체 점검

- `setup_actors` 테이블을 업데이트 하여 모든 인스트루먼트 사용 필요
- 활용
    - 메모리가 할당되어 있는 컨슈머
    - 특정 이벤트의 수 및 메트릭의 최댓값 확인 가능
    - 메모리 바이트 수 포함 