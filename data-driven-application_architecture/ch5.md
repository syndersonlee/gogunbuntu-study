# 5장 복제

복제가 필요한 여러가지 이유?

1. 지리적으로 사용자와 가깝게 유지하여 지연 시간 줄임
2. 장애가 발생해도 지속적으로 동작할 수 있도록 가용성 증대
3. 읽기 질의를 제공하는 장비의 수를 확장하여 읽기 처리량 증대

노드 간의 변경을 복제하기 위한 3가지 알고리즘

1. 단일 리더
2. 다중 리더
3. 리더 없는 복제

## 리더와 팔로워

일반적인 해결책은 <b> 리더 기반 복제 </b> 

- 리더를 지정하고 쓰기를 진행 할 때 리더로 요청을 보냄
- 팔로워에 해당하는 저장소가 새로운 데이터를 기록할 때마다 리더에서 팔로워에게 전송
- 클라이언트가 읽기 시 리더 또는 임의의 팔로워에게 질의 수행

### 동기식 대 비동기식 복제

- 복제가 동기식으로 발생하는 지 비동기식으로 발생하는 지 여부
- 장점
    - 팔로워가 리더와 최신 데이터에 대해 일관성을 가짐
- 단점
    - 팔로워가 응답하지 않으면 쓰기 처리 또한 불가
- 위의 이유로 모든 팔로워가 동기 식인 것은 비현실적
- 리더 복제 중 하나는 동기 / 하나는 비동기식으로 구현 - <b> 반동기식 구현 </b>
- 일반적인 리더 복제의 경우 완전한 비동기식으로 구현
    - 쓰기가 이루어져도 완전한 지속성을 미보장
    - 다만 팔로워와 관계 없이 쓰기 작업 수행 가능

### 새로운 팔로워 설정

새로운 팔로워가 리더의 데이터 복제본을 그대로 가지고 있는 지 보장 확인 방법

1. 리더의 데이터베이스 스냅샷을 일정 시점에 가져옴
2. 스냅샷을 팔로워 노드에 복사
3. 팔로워는 리더에 연결 하여 스냅 샷 이후 모든 데이터 변경을 요청
4. 스냅샷 이후의 백로그를 모두 따라 잡았을 경우 처리 가능

### 노드 중단 처리

리더 기반 복제에서 고가용성을 달성하는 방법이란?

#### 팔로워 장애 : 따라잡기 복구

- 로컬에 보관된 로그 확인
- 결함 이전의 트랜잭션 확인 후 리더에게 데이터 요청하여 따라잡기 진행

#### 리더 장애 : 쟁애 복구

- 팔로워를 리더로 승격하고 변경 후 재설정 필요 - failover

자동 장애 복구 방법은?

1. 리더가 장애인지 판단 (timeout으로 조치)
2. 새로운 리더를 선출 (제어 노드를 통해 임명)
3. 새로운 리더 사용을 위해 시스템을 재설정

이 때 발생 할 수 있는 부작용

- 이전 리더의 쓰기를 일부 수신 못할 수도 있음
- 유효하지 않은 데이터베이스 승격 / 이로 인한 정보 유출 등의 가능성
- 리더가 2개 이상 발생 가능 - <b>스플릿 브레인</b>
    - 데이터 분실 및 오염 가능
- 타임 아웃이 너무 짧을 시 장애 복구가 상황을 더 악화 시킬 수 있음

### 복제 로그 구현

리더 기반 복제의 내부 동작 방식

#### 구문 기반 복제

- 리더는 모든 쓰기 요청을 구문을 기록하고 실행 (SQL)

복제가 깨질 수 있는 다양한 사례는?

- NOW()나 RAND() 같은 비결정적 함수 호출 시
- UPDATE와 같이 데이터 내부 데이터 기반 프로세스의 경우 정확한 순서로 실행하지 않으면 발생
- 트리거 및 스토어드 프로시저에서 완벽하게 하지 않으면 부수 효과 발생 가능

위 사례에서 비결정적 함수를 호출하여 고정값 반환 하도록 할 수는 있지만 에지 케이스 발생 가능

#### 쓰기 전 로그 배송

1. SS테이블 및 LSM 트리의 경우 로그 세그먼트는 작게 유지되고 백그라운드로 가비지 컬렉션
2. 개별 디스크 블록에 덮어 쓰는 B트리의 경우 쓰기 전 로그에 쓰기 때문에 색인 복원 가능

- 위 두 케이스의 경우 append-only 바이트 열이기 때문에, 복제 서버 구축 가능
- 가장 큰 단점은 제일 저수준의 데이터 기술
- 리더와 팔로워 DB버전을 다르게 가져갈 수 없음
    - 이 방법은 업그레이드 시 중단 현상을 야기

#### 논리적(로우) 로그 복제

복제 로그를 다른 형태로 저장 -> 논리적 로그

- 모든 칼럼의 새로운 값을 포함
- 삭제된 로우의 로그는 로우를 고유하게 식별하는 데 필요한 정보를 포함
- 테이블에 기본키가 없다면 모든 칼럼은 예전 값을 로깅
- 논리적 로그 형식은 외부 어플리케이션에서 파싱하기 쉬움

-> 이를 <b>변경 데이터 캡처</b>라 부름

#### 트리거 기반 복제

- 오라클의 OGG같은 경우 데이터베이스 로그를 읽어 어플리케이션이 데이터를 변경 할수 있게 함
- Trigger 혹은 Stored Procedure을 사용하기도 함
- 트리거 기반 복사는 다른 복사보다는 제한 사항이 더 많이 발생

## 복제 지연 문제

- 확장성과 지연 시간 때문에 복제를 진행하기도 함

읽기 확장 아키텍처

- 팔로워를 추가함으로써 읽기 전용으로 활용
- 위 방식은 비동기 방식으로 사용
- 위 방식에서는 약간의 지연때문에 데이터 불일치가 일어나나 최종적으로는 리더와 일치하기 때문에 최종적 일관성을 보임

### 자신이 쓴 내용 읽기

자신이 쓴 글이 늦게 반영된다면 사용자는 유실되었다고 생각할 가능성이 있음 - <b>쓰기 후 읽기 일관성</b> 필요

- 수정한 내용은 리더에서 읽고 그 밖은 팔로워에서 읽음
- 갱신 후 1분 동안은 리더에서 모든 읽기 수행
- 복제 서버에서 최신 내용이 아닌 경우에는 질의를 대기 (타임 스탬프 활용)

여러 디바이스에서 읽기 일관성이 필요한 경우

- 메타 데이터를 중앙집중식 관리
- 리더에서 읽어야 할 접근법이라면 사용자 디바이스 요청을 동일한 데이터센터로 라우팅

### 단조 읽기

비동기식 팔로워에서는 시간이 거꾸로 흐를 수도 있음 -> 두번째 지연된 팔로워가 쓰기를 알지 못하는 경우

- 단조 읽기
    - 데이터를 읽을 때는 최종적 일관성 보다는 더 강한 보장
    - 하나의 데이터를 읽을 때 같은 레플리카 서버에서만 읽게 하는 방법

### 일관된 순서로 읽기

다른 파티션에 저장되는 데이터 때문에 사용자는 다른 상태로 존재하는 데이터의 파티션을 확인 할 수 있음

### 복제 지연을 위한 해결책

- 올바른 작업 수행을 위해 데이터베이스를 신뢰 할 수 있게 하기 위해 <b>트랜잭션</b>을 사용하여 강력한 보장 제공

## 다중 리더 복제

리더 기반 복제의 단점

- 리더에 연결 할 수 없다면, 데이터베이스에 쓰기를 할 수 없음
- 쓰기 허용하는 노드를 하나 이상 두는 것 = <b> 다중 리더 설정 - 마스터/마스터, 액티브/액티브 복제 </b>

### 다중 리더 복제의 사용 사례

다중 리더는 복잡도 때문에 사용하지 않지만 아래 케이스의 경우 사용

#### 다중 데이터 센터 운영

- 다중 리더 설정에는 하나의 데이터 센터에서 하나의 리더를 가지고 있음
- 하위 팔로워와 리더 간의 관계는 리더-팔로워 복제 사용
- 리더와 리더 간에는 변경 사항을 복제

단일 리더 설정과 다중 리더 설정 -> 다중 데이터 배포에서 이뤄지는 과정

- 성능
    - 인터넷을 통한 리더 복제가 이루어지기 때문에, 지연으로 인한 발생 문제로 인해 사용자에게 숨김
- 데이터센터 중단 내성
    - 하나의 데이터센터가 고장 나면 장애 복구를 위해 다른 데이터센터에서 팔로워를 리더로 승진
    - 센터 간 독립적으로 동작하기 때문에, 고장난 데이터 센터가 온라인으로 돌아오면 복제를 따라 잡음
- 네트워크 문제 내성
    - 인터넷을 통해 처리되기 때문에 비연결 상태에서도 쓰기 처리를 진행 할 수 있도록 함

문제점

- 동일 데이터를 동시에 다른 DB에서 변경하는 경우
- 설정상의 실수나 자동 증가 키, 트리거, 무결성의 제약에서 문제가 발생 가능

#### 오프라인 작업을 하는 클라이언트

인터넷 연결이 끊어진 경우에도 작업이 동작해야하는 경우

- 온라인 회의 경우
    - 로컬에서 비동기 방식으로 수행
    - 인터넷 연결 접근이 가능해 진 시점에 복제가 이뤄지도록 수행

#### 협업 편집

- 로컬 복제 서버에 적용하고 동일한 문서를 편집 하는 방법
- 트랜잭션을 사용하는 단일 리더 복제와 동일
- 또 다른 방법으로 변경 단위를 작게 하여 잠금 획득 처리

### 쓰기 충돌 다루기

다중 리더 복제의 가장 큰 문제

- 쓰기 충돌 - 같은 데이터에 데해 다른 값으로 동시에 변경할 경우 충돌 감지

#### 동기 대 비동기 충돌 감지

충돌 감지 방법 - 단일 리더

- 단일 리더 데이터베이스에서 첫 번째 쓰기가 완료될 때까지 두 번째 쓰기를 차단하여 대기
- 두 번째 쓰기 트랜잭션을 중단 시킴

#### 충돌 회피

- 충돌을 처리하는 가장 간단한 전략
- 모든 쓰기 작업이 동일한 리더 노드를 거치도록 함
- 한 사용자 기준으로 같은 홈을 바라봄
- 다만 다른 데이터 센터로 라우팅 상황이 발생한 경우는 위 케이스는 적용되지 않음

#### 일관된 상태 수렴

- 다중 리더에서는 쓰기 순서가 정해지지 않아 순서가 부정확
- 수렴 충돌 방식 해결
    - 각 쓰기의 UUID값(Timestamp)을 제공하여 가장 높은 ID를 가진 쓰기를 고름
    - <b>최종 쓰기 승리 방식</b>은 대중적이지만 데이터 유실 가능성이 존재
    - 각 서버에 고유 ID를 부여하고 낮은 숫자의 서버보다 높은 서버에 우선 순위 부여
    - 데이터를 병합하여 사전순으로 정렬하고 연결
    - 충돌을 기록하여 보존하고 사용자에게 명시(Merge Conflict)

#### 사용자 정의 충돌 해소 로직

쓰기 수행 중
- 충돌을 감지하자마자 충돌 핸들러를 호출
- 백그라운드 프로세스에서 빠르게 실행 하도록 처리

읽기 수행 중
- 모든 충돌 쓰기를 저장 이후 사용자에게 충돌 내용을 보여주어 해소

흥미로운 연구 주제들

- 충돌 없는 복제 타입 
    - Set, Map 등 데이터 구조의 집합으로 여러 사용자가 활용할 수 있도록 하는 구조체

- 병합 가능한 영속 데이터 구조
    - 깃 버전 제어 시스템과 유사한 추적 시스템 및 삼중 병합 함수 사용

#### 충돌은 무엇인가?

예를 들어 회의실을 동시에 예약하는 케이스

### 다중 리더 복제 토폴로지

<b>복제 토폴로지</b>

- 쓰기를 한 노드에서 다른 노드로 전달하는 과정

토폴로지 종류

- 전체 연결
    - 모든 리더가 각자의 쓰기를 모든 리더에게 전송
    - 다른 리더가 쓰기 전에 추월 가능성 존재
- 원형 토폴로지
    - 하나의 리더가 다른 리더에게 전달하는 방식
    - 문제 : Single Point Of Failure 
- 별 모양 토폴로지
    - 지정된 루트로 쓰기를 넘겨주고 전달
    - 문제 : Single Point Of Failure

## 리더 없는 복제

리더 없는 데이터베이스 스타일 - 다이나모 스타일

### 노드가 다운 됐을 때 데이터베이스에 쓰기

- 장애 복구가 필요하지 않고 여러 노드에서 데이터를 받음
- 클라이언트 버전 정보로 최신 정보만 습득

#### 읽기 복구와 안티 엔트로피

최종적 일관성을 위해 사용하는 메커니즘

- 읽기 복구
    - 클라이언트에서 읽기 중에 outdated 된 노드를 인지하고 새로운 값을 기록 하도록 진행 (자주 읽기가 진행 될 경우)
- 안티 엔트로피 처리
    - 백그라운드에서 프로세스에서 순회하면서 누락된 쓰기를 복제

#### 읽기와 쓰기를 위한 정족수

- n개의 복제 서버가 있을 때 w개의 노드가 성공해야 쓰기가 확정이라 가정하고 최소 r개의 노드에 질의 진행
- 일반적으로 w = r = (n + 1)
- r < n 이면 노드 하나를 사용할 수 없어도 여전히 읽기를 처리 가능
- w + r > n 이면 사용 불가능한 노드를 용인

### 정족수 일관성의 한계

- w + r > n이 되게 끔 w 와 r을 선택하면 일반적으로 모든 읽기는 최신 값 반환
- 읽은 노드 중에 최신 값을 가진 노드 하나 이상 있어야 함
- 이 때 n/2 노드 장애까지 허용해도 w + r > n을 허용
- w + r > n 이어도 최신 데이터를 반환하지 않는 에지 케이스 존재
    - 느슨한 정족수 사용
    - 두 개의 쓰기가 동시에 발생
    - 쓰기가 읽기와 동시에 발생할 경우
    - 쓰기가 일부의 복제 서버에만 성공
    - 새 값을 전달하는 노드의 고장

#### 최신성 모니터링

- 최신 데이터를 반환 유무를 확인하는 것은 중요한 문제
- 복제 지연에 대한 지표를 노출이 필요하지만 리더 없는 복제 시스템에선 어려움
- '최종 데이터'에 대한 정량화가 필요 

### 느슨한 정족수와 암시된 핸드 오프

- 네트워크 연결이 잘 될 경우 정족수를 채우지 못할 가능성이 많음
- 이 때 정족수를 채우지 못하더라도 가용한 노드에 기록하거나 정족수에 해당하지 않는 노드에 저장하는 것 = 느슨한 정족수
- 장애 해제 이후에 다시 메인 노드에 전송 하는 것 = 암시된 핸드오프
- 느슨한 정족수는 다이나모 DB 구현에서 선택 사항

#### 다중 데이터 센터 운영

- 리더 없는 복제 또한 동시 쓰기 충돌, 네트워크 중단 지연 시간 급증을 허용하기에 다중 데이터 센터 운영에 적합
- 쓰기에 있어서 비동기로 발생하게 끔 설정

### 동시 쓰기 감지

- 동시 쓰기를 허용하기 때문에 엄격한 정족수를 적용하더라도 충돌 발생 가능
- 해결을 위한 다양한 방법 소개

#### 최종 쓰기 승리(동시 쓰기 버리기)(LWW)

- "최신" 데이터를 모든 복제본에 쓰는 것
- 따라서 제일 큰 타임스탬프 기준으로 진행하고 이전 타임스탬프 사용 - 카산드라 Default / 리악에선 선택 기능
- LWW는 기존 쓰기가 삭제 될 수도 있음
- 가장 좋은 방법은 모든 쓰기에 UUID를 부여하는 것

#### "이전 발생" 관계와 동시성

- 두 가지 쓰기 방식에 인과관계가 존재 할 수 있음
- A -> B 이거나 A,B가 동시에 진행되었거나 의존 관계가 있는 경우 이를 파악해야 함

#### 이전 발생 관계 파악하기

- 어떤 작업이 이전에 발생했는지 이후에 발생하는 지 알지 못하지만 예전 값을 덮어 쓰기때문에 최종적으로는 손실된 쓰기가 없음
- 쓰기에서 이전 버전의 쓰기를 포함하면 수행 이전 상태를 알 수 있음

#### 동시에 쓴 값 병합

- 어떤 데이터도 자동으로 삭제되지 않음을 보장
- 이는 클라이언트가 직접 해소해주어야 하는 경우 또한 존재
- 일반적으로 합집합을 취함
- 합집합은 제거에 대해 올바른 결과를 얻지 못함
- 삭제 표시를 위해 버전 정보를 명시하고 이를 <b>툼스톤</b>이라고 명명

#### 버전 벡터

- 모든 복제본의 버전 모음을 <b>버전 벡터</b>라고 명명
- 값을 읽을 때 복제본을 클라이언트에 보내고 이를 서버에 전송
- 이 과정에서 형제 값이 올바르게 병합되게 진행

## 정리

복제의 다양한 용도
- 고가용성
- 연결 끊긴 작업
- 지연시간
- 
