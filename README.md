# PlanShare

일정을 공유하고 캘린더에 저장할 수 있는 앱입니다.

---

- 아키텍처: RIBs (frmework)
- 레이아웃: Flexlayout, (PinLayout)
- 패키지 매니저: Swift Package Manager
- 사용한 라이브러리: [ `Google Places API`, `RIBs`, `Firebase Firestore`, `RxSwift`, `RxGesture`, `Kakao SDK`, `Flexlayout/Pinlayout` ]


<br/>

## 화면 📱

|<img src = "https://user-images.githubusercontent.com/15855011/151779752-c3b26cb3-c3bd-490d-80e5-fb16da0cbceb.gif" width = 200>| <img src = "https://user-images.githubusercontent.com/15855011/151780779-4155c8c1-58f5-440f-a8ee-e29de03a454e.gif" width = 200> |
| :---------: | :---------: |
| `작성 화면` | `상세 보기` |
|  <img src="https://user-images.githubusercontent.com/15855011/151773864-463da470-f9c6-440d-bcea-bd7cef25e496.gif" width = 200>  |  <img src="https://user-images.githubusercontent.com/15855011/151773835-b3de263b-dfea-402d-9529-db6adac58906.gif" width = 200> |
| `공유 화면` | `전달 화면` |
| <img src = "https://user-images.githubusercontent.com/15855011/151778877-2aa44b60-ac23-4074-bb0e-a3b0623fb74d.gif" width = 200>|  <img src = "https://user-images.githubusercontent.com/15855011/151779122-00e91699-b264-4fe0-8dbd-79d45d63e054.gif" width = 200> |
| `캘린더 저장` | `지도 열기` |


## 기능 ⭐️

- 일정을 등록할 수 있습니다.
- 일정을 캘린더에 추가할 수 있습니다.
- 일정을 카카오톡을 이용해 공유할 수 있습니다.
- 일정 장소를 구글맵으로 열 수 있습니다.


## 아키텍처 ䷦

`RIBs` 를 이용하여 애플리케이션을 구성하였으며, RI 구조는 아래와 같습니다.

<img src = "https://user-images.githubusercontent.com/15855011/151781367-6de0bf0d-6636-4490-bf8e-61713ae3caeb.png" width = 300 >

