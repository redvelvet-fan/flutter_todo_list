# Flutter To-Do List Application

## 설명
Flutter로 제작된 이 To-Do List 애플리케이션

## 주요 기능
- 할 일을 제목, 설명, 마감 기한과 함께 등록 가능
- 한 번의 클릭으로 할 일 완료 처리 및 완료 시간 자동 기록
- 완료된 할 일을 수정하거나 상태를 다시 진행 중으로 변경 가능

## 기술
- 내부 저장소로 SQLite 사용, `sqflite` 및 `sqflite_common_ffi` 라이브러리 사용
- GetX(`get`)를 활용하여 앱 시작 시 저장된 값을 불러오고 진행 중, 완료된 항목을 분류
- GetXController를 통한 데이터 관리
- 드래그 앤 드롭을 이용한 재정렬 가능, LinkedList 방식으로 효율적인 순서 변경 구현
- 앱 내 데이터는 내부 저장소와 실시간 연동되며, 시각적 효과를 위해 현재 상태와 내부 저장소 순으로 데이터 적용
- 내부 저장소 오류 시 이전 상태로 복구, 데이터의 일관성 유지

## 테스트
- Todo Task CRUD 기능 단위 테스트
- Todo Task 재정렬 기능 단위 테스트
- Localizations 테스트
