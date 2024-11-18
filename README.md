# MemoSnap - AI 기반 스마트 다이어리 앱 📸

## 프로젝트 소개
MemoSnap은 AI 기술을 활용한 스마트 다이어리 앱입니다. 사진 한 장으로 그날의 기억을 자동으로 일기로 작성해주며, 위치 기반 서비스를 통해 장소와 함께 추억을 기록할 수 있습니다. ( 현재 작업 진행 중에 있습니다. )

![앱 스크린샷]()  // 나중에 스크린샷 추가

## 주요 기능
### 1. AI 기반 자동 일기 생성
- 사진 분석을 통한 자동 일기 내용 생성
- LM Studio와 Mistral-7B-Instruct 모델 활용
- Google Cloud Vision API를 통한 이미지 인식

### 2. 위치 기반 기록
- Google Maps API 연동
- 현재 위치 자동 저장
- 장소별 일기 필터링

### 3. 실시간 데이터 동기화
- Firebase Realtime Database 활용
- 멀티 디바이스 지원
- 오프라인 모드 지원

### 4. 보안 및 사용자 관리
- Firebase Authentication을 통한 안전한 로그인
- Google 소셜 로그인 지원
- 사용자 데이터 암호화

## 기술 스택
### Frontend
- Flutter/Dart
- Provider 상태관리
- Cached Network Image
- Custom Animations

### Backend
- Firebase
  - Authentication
  - Cloud Firestore
  - Realtime Database
- Flask/Python
- Cloudinary (이미지 저장소)

### AI/ML
- LM Studio
- Mistral-7B-Instruct-v0.1-GGUF
- Google Cloud Vision API

## 아키텍처
```
lib/
├── models/
│   ├── diary.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   └── diary_provider.dart
├── screens/
│   ├── auth_screen.dart
│   ├── diary_detail_screen.dart
│   └── ...
└── services/
    ├── api_service.dart
    └── cloudinary_service.dart
```

## 주요 구현 사항
1. **MVVM 아키텍처 패턴**
   - Provider를 활용한 상태 관리
   - 비즈니스 로직과 UI 분리

2. **반응형 디자인**
   - 다양한 화면 크기 지원
   - 부드러운 애니메이션 효과

3. **데이터 최적화**
   - 이미지 캐싱
   - 효율적인 데이터 구조
   - 실시간 동기화 최적화

4. **보안**
   - 사용자 인증
   - 데이터 암호화
   - 안전한 API 통신

## 설치 방법
```bash
# 저장소 클론
git clone https://github.com/yourusername/memosnap.git

# 종속성 설치
flutter pub get

# 실행
flutter run
```

## 환경 설정
1. Firebase 프로젝트 설정
2. Google Cloud Platform API 키 설정
3. Cloudinary 계정 설정

## 향후 계획
- [ ] 테마 커스터마이징
- [ ] 공유 기능 강화

## 팀 소개
// 개인 Flutter project
