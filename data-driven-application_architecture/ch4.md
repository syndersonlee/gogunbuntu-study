# 4장 부호화와 발전

- 대부분의 경우 기능 변경 = 데이터의 변경

데이터의 변경에 대처하는 데이터 모델의 방법?

- 관계형 데이터베이스의 경우 스키마가 변경
- 읽기 스키마 데이터베이스는 강요 X

대규모 업데이트에 대처하는 코드 변경 방법

- 서버 측 어플리케이션의 경우 몇 개의 노드에 새 버전을 배포하고 이후 나머지를 배포하는 Rolling 배포를 사용
- 클라이언트는 사용자에 의해 좌우

변경 시 중요하게 유지해야하는 점

- 하위 호환성
- 상위 호환성

## 데이터 부호화 형식

- 프로그램은 일반적으로 두 개 이상의 데이터 형태를 사용해 표현
- 포인터 및 바이트 열은 메모리에서 사용하는 데이터 구조와 달라 다른 프로세스에서 이해가 불가능
- In-Memory -> 바이트 열의 변환을 직렬화, 마샬링이라고 지칭 / 반대는 파싱, 역직렬화, 언마샬링

### 언어별 형식

프로그래밍 언어에 내장되어 있는 직렬화 문법의 어려운 점이란?

- 부호화를 통해 저장하고 전송할 경우 현재 프로그래밍 언어로 전송해하고 다른 언어와 통합에 방해
- 복호화 과정에서 임의의 클래스를 인스턴스화 가능해야 하며, 이는 공격자가 원격으로 임의의 코드를 실행할 수 있음
- 버전 관리 과정에서 상하위 호환성이 등한 시
- 효율성이 떨어지는 점

### JSON과 XML, 이진 변형

- JSON, XML, CSV는 텍스트 형식 및 사람이 읽을 수 있음

피상적인 문법 이외에 가지고 있는 미묘한 문제

- XML, CSV는 수와 숫자 문자열 구분이 어려움 / JSON은 문자열과 수를 구분 그러나 부동소수점 수 및 정밀도 미지정
- 큰 수를 다룰 때 JSON에서 문제가 발생
- JSON과 XML은 유니코드는 잘 지원 그러나 이진 문자열은 미지원하여 Base64를 사용하는데 이 때 데이터 크게 33% 증가
- XML의 스키마는 꽤 널리 사용, JSON 기반 도구는 스키마를 미강제 하기 때문에 부호화 시에 하드코딩 해야한느 가능성 존재

위와 같은 문제들이 있음에도 다양한 용도로 사용하기 충분

#### 이진 부호화

- JSON은 XML보다 덜 장황하지만 이진 부호보다 훨씬 많은 공간 사용
- 특정 JSON 형태는 모든 객체의 필드 이름을 포함 해야함

### 스리프트와 프로토콜 버퍼

- 스리프트와 프로토콜 버퍼는 같은 원리를 기반으로 한 이진 부호화 라이브러리 
- 부호화할 데이터를 위한 스키마 필요
- 스키마의 레코드를 부호화하고 복호화할 수 있음

스리프트 스키마 예시

```
struct Person {
    1: required string userName,
    2: optional i64 favoriteNumber,
    3: optional list<string> interests
}
```

프로토콜 버퍼 예시

```
message Person {
    required string user_name = 1;
    optional int64 favorite_number = 2;
    repeated string interests = 3;
}
```

스리프트의 부호화 데이터 형태

- 바이너리 프로토콜
- 컴팩트 프로토콜

바이너리 프로토콜과 스리프트 프로토콜 차이점

- 스리프트 프로토콜은 필드이름이 없고 필드 태그를 통해 필드를 알 수 있음
- 컴팩트 프로토콜은 동일한 데이터를 필드 타입과 태그 숫자를 단일 바이트로 줄여 용량을 줄임
- 프로토콜은 비트를 줄여 처리하는 방법은 다르지만 컴팩트 프로토콜과 비슷함

#### 필드 태그와 스키마의 발전

상위 호완성

- 스키마가 변경됨에 따라 새로운 태그 번호를 부여할 수 있음
- 필드 태그는 변경 될 수 없음으로 필드에 새로운 태그 번호를 부여하여 필드 태그를 추가

하위 호완성

- 새로운 필드를 required로 추가한 경우 예전 코드는 새로운 필드를 미기록하여 읽기 실패
- 이를 위해 optional로 제공하거나 기본값을 가져야 함

필드 삭제 시
- optional 필드만 삭제 가능하고 같은 태그 번호는 절대 다시 사용할 수 없다.

#### 데이터 타입

데이터 타입을 변경 할 경우 
- 32비트를 64비트 정수로 바꿀 경우 누락한 비트를 0으로 채울 수 있기 때문에 쉽게 읽을 수 있음
- 예전 코드를 읽기 위해 32비트를 그대로 사용

프로토콜 버퍼의 repeated 표시자

- 단순한 필드 태그가 여러 번 등장
- optional -> repeated로 변경해도 문제 없음

스리프트의 전용 목록 데이터 타입은 

- 프로토콜 버퍼와 다르게 다중값으로의 변경은 미허용
- 중첩된 목록 허용

### 아브로

하둡 하위 프로젝트로 시작한 부호화 형식

이진 부호화 형식

- 사람이 편집할 수 있는 IDL이고, 기계가 더 쉽게 읽을 수 있는 JSON 기반 형식
- 스키마에 태그 번호 미존재 
- 데이터 타입을 식별하기 위한 정보가 없고, 정확하게 같은 스키마를 통해 복호화 제공

#### 쓰기 스키마와 읽기 스키마

- 쓰기 스키마 : 데이터를 전송 등의 목적으로 부화 할 때 쓰는 스키마
- 읽기 스키마 : 파일 / 데이터 등에서 읽은 데이터를 복호화 할 때 쓰는 스키마 - 어플리케이션 코드에서 의존

아브로의 특징

- 읽기 스키마와 쓰기 스키마가 동일하지 않아도 되며, 호환만 가능하면 처리 가능
- 데이터를 복호화 시 쓰기 스키마에서 읽기 스키마로 데이터를 변환하여 처리
- 필드가 달라도 스키마 해석으로 이를 처리

#### 스키마 발전 규칙

- 아브로 상위 호환성 = 새로운 버전의 쓰기 스키마 / 예전 버전의 읽기 스키마
- 아브로 하위 호환성 = 새로운 버전의 읽기 스키마 / 예전 버전의 쓰기 스키마

아브로 호환성의 특징

- 호환성 유지를 위해서는 기본값이 있는 필드로 채워져야 함
- 기본 값이 없는 필드를 추가할 경우 예전 읽기가 새로운 쓰기를 읽을 수 없음
- 유니온 타입을 제외하고는 Null을 미허용
- optional, required 표시자가 없고 union 사용
- 필드의 데이터타입과 이름이 변경 가능하지만 하위 호완성은 있지만 상위 호환성은 없음 -> 새로운 읽기 버전만 쓰기 버전에 반영 가능하다는 것

#### 쓰기 스키마란 무엇일까요?

읽기 스키마가 부호화 한 쓰기 스키마를 알 수 있는 방법은? (스키마가 부호화 된 데이터보다 클 수 있기 때문에)

- 많은 레코드가 있는 대용량 파일의 경우
    - 동일한 스키마로 부호화 된 수백만 개를 저장함으로 파일 시작 부분에 쓰기 스키마를 한번만 포함
- 개별적으로 기록된 레코드
    - 스키마 버전 번호를 추출하여 해당하는 쓰기 스키마를 가져옴
- 네트워크 연결을 이용한 레코드
    - 양방향 네트워크를 통해 통신할 때 스키마 버전을 합의 할 수 있음
    - RPC 프로토콜이 이와 같은 예

#### 동적 생성 스키마

- 태그 번호가 미포함되어 있기 때문에 각 테이블에 맞게 레코드 스키마를 생성하고 레코드의 필드에 매핑
- 데이터 베이스 스키마가 변경이 되어도 데이터 자체에는 스키마 태그 번호가 없기 때문에 이름으로 식별하여 매치가 가능
- 반대로 스리프트나 프로토콜 버퍼는 이를 필드 태그를 수동으로 할당 필요

#### 코드 생성과 동적 타입 언어

- 스리프트와 프로토콜은 정적 타입 언어에서는 인메모리 구조를 사용하여 검사기 또는 타입 확인 등 가능
- 반대로 동적 언어에서는 컴파일 타임에 생성하는 것이 중요하지 않음
- 아브로는 반대로 코드 생성을 선택적으로 제공하고 라이브러리를 통해 열어보는 것도 가능
    - 언어 의존성이 적음

### 스키마의 장점

- 이진 부호화 스키마의 대부분 XML언어나 JSON 스키마 보다 훨씬 간단하고 더 자세한 유효성 검사 규격을 지원
- 또한 데이터베이스 벤더나 복호화 드라이버를 벤더에서 제공하는 경우가 많기 때문에 드라이버를 제공

이진 부호화의 좋은 속성

- 필드 데이터가 생략 가능하기 때문에 이진 JSON 변형보다 크기가 훨씬 작을 수 있음
- 복호화 시 스키마가 필요하기 때문에 최신 버전인지 확인 가능
- 스키마 데이터베이스를 유지하면 상위 호환성이나 하위 호환성을 확인 가능

## 데이터플로 모드

하나의 프로세스에서 다른 프로세스로 데이터를 전달하는 방법

### 데이터베이스를 통한 데이터플로

- 프로세스는 데이터를 부호화하고 프로세스는 데이터를 복호화 => 읽기는 프로세스의 최신 버전
- 객체를 읽고 다시 부호화 하는 과정에서 DB에 새로운 데이터 유입이 있다면, 알지 못하는 데이터가 유실 가능성이 있지만 이를 인지하고 방지가 가능

#### 다양한 시점에 기록된 다양한 값

- 데이터는 명시적으로 기록하지 않는 이상 부호화 상태로 존재
- 일반적으로 누락된 칼럼은 널로 기록
- 링크드인의 경우 아브로를 사용

#### 보관 저장소

- 데이터의 스냅샷을 주기적으로 저장흠으로 복사본을 일관되게 부호화
- 데이터 덤프를 한 번에 기록하고 변하지 않으므로 아브로를 사용하는 것이 적당

### 서비스를 통한 데이터플로 : REST와 RPC

- 서버 자체가 다른 서비스의 클라이언트일 수 있음
- 하나의 서비스를 소규모로 나누어 이를 통신 하는 것을 SOA라 부르며 이를 개선하여 MSA라 부르기로 함
- DB는 질의를 사용하는 반면, 서비스는 전용 어플리케이션 API와 캡슐화를 제공
- 따라서 서버와 클라이언트가 사용하는 서비스의 데이터 부호화는 API 버전 간 호환이 가능해야 함

#### 웹 서비스

웹 서비스를 사용하는 다양한 판례

1. 사용자 디바이스를 통해 서비스를 요청하는 클라이언트 어플리케이션
2. SOA/MSA의 일부로 다른 서비스에 요청하는 서비스 (미들웨어라 지칭)
3. 다른 조직의 백엔드 시스템 간 데이터 교환을 위해 사용 (ex. OAuth)

Rest vs SOAP

1. Rest는 HTTP의 원칙을 토대로 한 설계 철학
2. SOAP는 네트워크 API 요청을 위한 XML 기반의 프로토콜 - WSDL을 통해 구현(그러나 사람이 이해 불가)
    - 다른 벤더 간 서비스 통합이 어려움

#### 원격 프로시저 호출(RPC) 문제

RPC 모델의 특징

- 특정 프로그래밍 언어의 함수나 메소드를 호출하는 것처럼 사용 가능
- 다만 네트워크 호출은 예측이 어려움으로 실패한 요청에 대한 재요청에 대한 대책을 세워야 함

네트워크 통신 유실 가능성

- 타임아웃으로 결과값 없이 반환 가능
- 실제로 처리 후 응답만 유실 가능 (같은 동작 여러 번 수행)
- 지연 시간이 매우 다양하여, 오래 걸릴 수 있음
- 바이트열로 부호화 해야하기 때문에 이 과정에서 문제 발생 가능
- 서로 간의 다른 언어를 사용하는 경우 변환이 필요하여 문제 발생 가능

#### RPC의 현재 방향

- 피네글 - 스리프트 사용 / Rest.li - HTTP, JSON 사용 / gRPC는 프로토콜 버퍼를 이용한 RPC 구현
- 피네글과 Rest.li는 비동기 작업을 캡슐화하는 퓨처를 사용하여 병렬로 요청을 보내고 이 결과를 취합
- gRPC는 시간에 따른 요청과 응답으로 구성된 스트림 지원

Rest vs RPC

- 이진 부호화 형식의 사용자 정의 프로토콜은 우수한 성능을 가지지만 REST에 비해 디버깅 및 프로그램 설치 없이 다양한 언어와 도구를 사용할 수 있음

#### 데이터 부호화와 RPC의 발전

- 일반적으로 모든 서버를 먼저 갱신 -> 클라이언트 갱신을 가정 (하위 호환성만 필요)
- 서비스 제공자의 경우 일반적으로 호환성이 오랜 시간 동안 유지 되어야 함

### 메시지 전달 데이터 플로

비동기 메시지 전달 시스템이 RPC와 비교했을 때 가지는 장점
- 수신자가 사용 불가능 해도 브로커가 버퍼처럼 동작 가능
- 송신자가 수신자의 IP를 알 필요 없음
- 하나의 메시지를 다중 수신자가 받기 가능

#### 메시지 브로커

- 메시지 브로커는 큐나 토픽으로 전달하고 소비자나 구독자에게 메시지를 전달
- 메시지 브로커는 특정 데이터 모델을 강요하지 않기 때문에 유연성을 갖게 된다.

#### 분산 액터 프레임워크

엑터 모델

- 단일 프로세서 안에서 동시성을 위한 프로그래밍 모델
- 로직이 엑터 안에서 캡슐화
- 메시지 전달을 미보장하며 한번만 전달

분산 액터 프레임워크 

- 여러 노드 간에 어플리케이션 확장에 사용
- 어느 노드에 있던지 같은 메시지 전달 구조 사용

액터 프레임워크의 3종류
- 아카
    - 자바 내장 직렬화 사용하며, 상하위 호환성 미제공
- 올리언스
    - 사용자 정의 데이터 부호화 형식 사용
    - 순회식 업그레이드 미지원
- 얼랭
    - 순회식 업그레이드를 할 수 있도록 하는 새로운 구조
    