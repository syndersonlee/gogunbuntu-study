
# 1. 단위 테스트의 목표

- 지속 가능한 성장을 목표로 작성
    - 시간이 지날 수록 코드의 엔트로피는 증가
    - 엔트로피 증가에 따른 서비스 확장 비용은 기하급수적으로 증가
    - 테스트 코드는 이에 대한 방충망 역할

- 테스트의 가치
    - 기반이 되는 코드를 리팩토링할 때는 테스트 또한 리팩토링 
    - 기반 코드 이해가 필요할 시 테스트를 읽어라

- 커버리지 지표
    - 코드 커버리지 지표
        - 제품 코드 라인 수 / 전체 라인 수
    - 분기 커버리지 지표
        - 통과 분기 / 전체 분기

- 커버리지 지표의 무의미성
    - 모든 결과를 대표하지 않음
    - 검증이 없는 테스트 케이스
    - 외부 라이브러리의 코드 고려 불가

- 좋은 테스트 스위트란?
    - 개발 주기에 통합되어 있는 것
    - 코드 베이스에서 가장 중요한 비즈니스 로직이 있는 부분
    - 가치 있는 테스트를 테스트
        - 가치 있는 테스트 식별
        - 가치 있는 테스트 작성


# 2. 단위 테스트란 무엇인가?

- 테스트의 두 가지 견해
    - 고전파
    - 런던파

## 단위 테스트에 대한 고전파와 런던파의 견해

- 고전파의 방식은 협력자 클래스는 Mocking으로 대체하지 않고, 운영용 인스턴스를 사용한다.
- 런던파의 방식은 협력자 클래스는 Mocking을 사용하여 정의하고 각 메서드 별 호출 값을 직접 정의하여 응답 값으로 회신
- 따라서 고전파의 방식은 협력자 클래스에 대한 상호 작용 까지 검사가 가능하지만 협력자의 상태에 영향을 받음
- 런던파는 영향을 받지는 않지만 상호 작용에 대한 검사가 불가

### 런던 스타일로 작성된 테스트

- 테스트 sut 대상을 제외하고 협력자를 테스트 대상에서 격리하고 진행

### 고전파의 접근

- 외부 의존성 상태를 공유하여 사용
- 두 가지 이상 테스트를 병렬적으로 사용할 경우 하나가 실패할 가능성이 높음
- 공유 의존성의 호출은 오랜 시간이 걸리기 떄문에 이런 호출을 포함할 경우 통합 테스트의 영역으로 넘어감


## 단위테스트의 런던파와 고전파

- 값의 경우 언어에 의존성을 가진 인스턴스
- 고전파에서는 공유 의존성만을 Mocking 처리
- 런던파에선는 변경 가능한 의존성과 공유 의존성 모두 MockIng 처리
- 외부 의존성와 프로세스 외부 의존성 용어는 서로 바꿀 수 있게 사용
    - 외냐하면 프로세스 내부에 있지 않는 경우 접하지 않을 가능성이 높음
    - 내부 인스턴스는 공급 가능

### 고전파와 런던파 비교

- 런던파의 장점
    - 입자성이 좋고, 테스트가 쉽고, 실패에 대한 이유를 알 수 있음
    - 런던파의 경우 클래스 단위로 한 번에 하나의 클래스를 테스트

- 고전파의 장점
    - 응집도가 높고, 의미가 있는 테스트가 가능
    - 버그가 발생 시 테스트 디버깅이 더 소요 되지만, 큰 문제는 안된다

### 차이점

- 런던 스타일은 하향식 TDD를 사용한 경우가 있음
- 전체 시스템에 대한 기대를 먼저 설정 이후 상위 레벨 테스트 이후 하위로 내려옴
- 반대로 고전파는 도메인 부터 상향식으로 발전

## 통합 테스트

- 고전파 기준 단위 테스트 = 런던파 기준 통합 테스트
- 데이터 베이스 상태가 변경이 생기면, 모든 테스트의 결과가 변경
- 또한 외부 의존성 접근 시 테스트가 느려짐
- 시스템 전체를 검증하여 소프트웨어 품질을 기여하는 데 중요한 역할

## 엔드 투 엔드 테스트

- 사용자 관점에서 의존성을 전부가지고 진행하는 테스트
- 다만 모든 외부 의존성을 가져오더라도 일부 의존성은 결국 모킹해야할 필요성이 있다.


# 3. 단위 테스트 구조

- AAA 패턴
    - 준비
        - sut과 의존성을 원하는 상태로 만듬
    - 실행
        - sut이 메소드를 호출하고 의존성을 전달하며 출력값을 캡처
    - 검증
        - 결과 값에 대해서 최종 상태를 검증

- 일반적인 단위 테스트 단위에서는 실행 구절이 하나로만 구성
- 통합테스트에서는 실행 구절이 여러 개로 이루어 질 수 있음

- 주의 사항
    - 테스트 내에 if문 피하기
    - 준비 구절이 큰 경우 팩토리 클래스나 비공개 메서드로 분리
    - 실행 구절이 두 줄 이상인 경우 공개 API 상에 문제가 있을 수 있음
        - 구매와 재고 감소는 하나로 묶여야 함
    - 검증 구절이 너무 커도 안된다
    - 종료 단계에서 데이터베이스 연결 종료 등의 코드는 AAA 패턴에 속하지 않음


## 테스트 픽스처 사용

- 테스트 이전에 공통 구성 로직을 호출 하여 재활용 가능
- 다만 테스트 간 높은 결합도 때문에 초기 상태에 대한 가정이 달라짐
- 또한 생성자 자체가 갖는 가독성이 떨어지는 부분이 문제로 발생


### 더 나은 테스트 픽스처 사용

- 비공개 팩토리 메소드로 추출해서 생성자를 대체
- 테스트 전체에 대한 생성자에 인스턴스화 가능

### 매개 변수화 된 테스트 리팩토링

- 특정 인수 값에 따라 결과 값을 확인 할 수 있고 이에 대한 로직이 동일한 경우
    - 위 테스트를 별도의 테스트가 아닌 InlineData라인으로 묶여서 개별 파라미터로만 테스트 가능
    - 다만 이에 대한 가독성을 떨어짐

- 매개변수화 된 데이터를 생성하여 파라미터로 사용하는 경우 컴파일러가 이를 인식 불가
- 정적 메서드 값을 받아 처리하는 방법으로 해결 가능