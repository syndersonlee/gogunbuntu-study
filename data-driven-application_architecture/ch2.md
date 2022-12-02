# 2장 데이터 모델과 질의 언어

데이터 모델을 표현 하는 방법?

1. 객체나 데이터 구조 API를 모델링 - 어플리케이션
2. JSON, XML로, RDB 형태로 저장 - 파일 형태
3. 위 파일을 네트워크 및 그래프 상의 파이프로 표현 - 엔지니어
4. 더 낮은 수준에서 하드웨어 엔지니어는 전류, 빛의 파동 관점에서 바이트를 표현 - 하드웨어 개발자

이번 장의 주제는?

- 관계형 모델, 문서 모델, 그래프 기반 데이터 모델을 비교
- 질의 언어 및 사용 사례

## 관계형 모델과 문서 모델

최초의 모델 및 이후 모델

- 관계로 구성되고, 순서 없는 튜플의 모음
- 이후 네트워크 모델 및 계층 모델이 등장했지만, 관계형이 범용적으로 사용

### NOSQL의 탄생

NoSQL 채택했을 때의 특징

- 관계형 데이터베이스보다 뛰어난 확장력
- 오픈 소스 선호 현상
- RDBMS에 없는 특수 질의 동작
- RDBMS의 제한적 스키마와 동적이고 풍부한 표현력을 가진 DB

### 객체 관계형 불일치

어플리케이션 레이어와 DB 모델 객체 간의 전환이 필요

- 임피던스 불일치

임피던스 불일치를 줄이는 방법

- JSON 모델을 사용한 계층 분리

### 다대일의 다대다 관계

항목에 대한 리스트업 혹은 드롭다운 필드를 제공함으로서 얻는 이점?

1. 일관된 스타일 및 철자
2. 모호함 타피
3. Localization
4. 갱신
5. ** 중복 문제 해결

ID 사용 장점

- ID 자체가 보통 의미를 가지지 않기 때문에 일반적으로 변경의 필요성이 없음

다대일 관계의 특징

- 초기에는 조인 없는 문서 모델로 사용하더라도 JOIN이 추가되면서 상호 연결 되는 경향이 있음
- 문서 데이터 베이스는 이러한 조인의 지원이 약함

### 문서 데이터베이스는 역사를 반복하고 있나?

다대다 관계를 가장 좋은 방법으로 표현하기 위한 방법 (역사)

1. IBM에서 출시한 IMS(계층 모델) ===== JSON 모델
2. 이후 관계형 모델(SQL) & 네트워크 모델 간의 논쟁이 발생

#### 네트워크 모델 = 코다실 모델

- 모든 레코드는 정확하게 하나의 부모 존재 (Like 포인터)
- 최상위 경로를 통해 연속된 연결 경로를 따름
- Query 시 모든 DB의 모든 값을 Tracking 해서 수행
- 경로가 없을 경우 탐색이 어려움
- 데이터 모델 변경 작업 또한 어려움

#### 관계형 모델

- 튜플과 컬렉션으로 구성
- 질의 최적화기가 접근 순서를 결정하고 사용할 색인을 자동으로 결정

#### 문서 DB와 비교

- 문서 DB와 RDB의 차이는 상위 레코드 내 중첩된 레코드를 저장
- 조인 다대일, 다대다를 RDB가 더 나은 성능으로 지원
- 스키마 유연성, 지역성은 문서 DB가 더 잘 지원

### 관계형 데이터베이스와 오늘날의 문서 데이터베이스

#### 어떤 데이터 모델이 어플리케이션 코드를 간단하게 할까?

- 문서와 같은 형태라면 문서 모델이 좋음(일대다 트리 형태)
- 문서 DB는 조인 지원이 미흡함
    - 로그나 이벤트 기록이 좋음
- 조인을 자주 사용할 경우 RDB가 좋음

#### 문서 모델에서의 스키마 유연성

- JSON은 문서에 스키마 고정 강요 X
- 스키마 변경은 느리고 중단 시간을 요구
- 외부 시스템에 의존성이 심한 데이터 형태인 경우 스키마 리스가 더 나음

#### 질의를 위한 데이터 지역성

- 문서의 많은 부분을 필요로 할 때, 작은 부분에만 접근 해도 전체 적재 필요
- 이 때문에 문서를 작게 유지하는 문서 DB가 유용한 상황이 줄어듬
- 오라클에서는 다중 테이블 색인 클러스터 테이블 제공

#### 문서 DB와 RDB의 통합

- 많은 RDB에서 JSON 지원 기능 추가
- 문서형에서는 질의 언어에서 관계형 조인을 지원

## 데이터를 위한 질의 언어

쿼리 언어들의 특징

- IMS / 코다실은 명령형 언어를 사용
- SQL 또한 관계 대수의 구조를 활용하여 컴퓨터에게 지시
- SQL 예제는 순서를 모장하지 않음 -> DB에게 최적화 요구 가능

### 웹에서의 선언형 질의

- 선언형 질의는 이해하기 쉬움
- 호환성을 취하기 어렵고, 반응성이 떨어짐 - 명령형

### 맵리듀스의 질의

맵리듀스의 질의 특징?

- 명령형과 질의 API의 중간에 속함
- 저수준 프로그래밍 모델
- 순수 함수만 사용해야 함

## 그래프형 데이터 모델

그래프 형 데이터 예시

- 소셜 그래프
- 웹 그래프
- 도로, 철도 네트워크

속성 그래프 종류

- Neo4j
- Titan
- InfinteGraph

트리플 저장소 모델

- Datomic
- Allegropgraph

### 속성 그래프

각 Vertex의 요소

- 고유한 식별자
- 인풋 간선 집합
- 아웃품 간선 집합
- Key-Value 데이터

각 Line의 요소

- 고유한 식별자
- 인풋 시작 정점
- 아웃품 시작 정점
- 관계 유형 레이블
- Key-Value

특징

- 정점과 정점을 간선으로 연결
- 그래프를 통해 순회 가능
- 다른 유형의 정보를 저장해도 데이터 모델 깔끔하게 유지 가능

### 사이퍼 질의 언어

특징

- 속성 그래프를 위한 선언형 질의 언어
- 유입 간선을 따라 트래킹 하는 구조

### SQL의 그래프 질의

- SQL을 통해서도 질의는 가능하지만, 여러 간선 순회에 의한 조인 수 고정 불가
- SQL을 통해서도 그래프형에 대해 재귀적으로 질의 가능하지만, 사이퍼에 비해 문법이 어려움
- 사이퍼 언어 4줄 vs SQL 29줄로 작성

### 트리플 저장소와 스파클

특징

- 속성 그래프 모델과 비슷함
- 모든 정보를 주어, 서술어, 목적어로 구분

#### 시맨틱 웹

- 기계가 이해할 수 있도록 웹을 일관성 있게 적용한 형태
- 하지만 표준이 복잡하고 약어가 복잡하여 현실화 X

#### RDF 데이터 모델
#### 스파클 질의 언어

특징

- 스파클의 경우 사람이 이해할 수 있도록 XML 형태로 만든 언어
- 스파클은 RDF 데이터 모델을 사용
- 어플리케이션 내부에 적재적소에 활용하여 강력하게 이용 가능

### 초석 : 데이터 로그

특징

- 트리플 저장소 모델과 유사하지만 조금더 일반화
- 하둡 대용량 질의를 위한 용도
- 사이퍼와 스파클과 달리 단계를 나누어 질의
- 간단한 일회성 질의 사용이 어려움

## 정리

DB의 갈래

- RDBMS
- NOSQL
    - 문서 DB
    - Graph형 DB