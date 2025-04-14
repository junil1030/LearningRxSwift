//
//  ViewController.swift
//  RxSwiftBasic
//
//  Created by 서준일 on 4/8/25.
//

import RxSwift
import RxCocoa
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var editView: UITextView!
    
    let button = UIButton()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
        
        button.rx.tap
            .subscribe(onNext: {
                print("Button clicked!")
            })
            .disposed(by: disposeBag)
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe
    // 3. onNext
    // ---- 끝 ----
    // 4. onCompleted   /   on Error
    // 5. Disposed
    
    func downloadJson(_ url: String) -> Observable<String?> {
        // 단지 Hello World!를 보내야하는데 너무 코드가 길어짐..
//        return Observable.create() { f in
//            f.onNext("Hello World!")
//            f.onCompleted()
//
//            return Disposables.create()
//        }
        
        // 그래서 아래처럼 just 키워드로 보내면 onNext, onCompleted를 모두 한 것과 같은 효과
        //return Observable.just("Hello World!")
        
        // 근데 간단한 메세지지만 두개 이상을 보내야 할 때에는?
        // return Observable.just(["Hello", "World!"])
        // 이렇게 해도 되지만 그렇게 되면 배열로 옵셔널 씌워진 단어 두개가 같이 가게됨.
        // 그러므로 이럴 때에는 from을 사용한다.
        // return Observable.from(["Hello", "World!"])
        
        // 이렇게 한줄로 표현하는 것들을 sugar API라고 함..
        
        
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }
                
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
        }
        
        
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()
//                }
//            }
//
//            return Disposables.create()
//        }
    }
    
    //MARK: - SYNC
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func onLoad(_ sender: Any) {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
//        // 2. Observable로 생기는 데이터를 받아서 처리하는 방법
//        _ = downloadJson(MEMBER_LIST_URL)
//            .debug()
//            .subscribe { event in
//                switch event {
//                case .next(let json):
//                    DispatchQueue.main.async {
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//
//                case .completed:
//                    break
//                case .error:
//                    break
//                }
//            }
        // 매번 이렇게 complete와, error를 처리를 해줘야 하는데 이게 필요없을 때에는 어떻게 하냐?
        
//        _ = downloadJson(MEMBER_LIST_URL)
//            .subscribe(onNext: { print($0) },
//                       onError: { err in print(err) },
//                       onCompleted: { print("completed") }
//            )
        // 이런식으로 처리를 할 수 있음.
        
        _ = downloadJson(MEMBER_LIST_URL)
            .observe(on: MainScheduler.instance) // 이렇게 메인 인스턴스를 끼워주면 알아서 메인에서 동작함 이것도 모두 sugar api : operator
            .subscribe(onNext: { json in
                // 근데 항상 이렇게 UI 관련 작업일 때 디스패치 메인으로 감싸주는 게 너무 귀찮음 이걸 해결하기 위해서
                //DispatchQueue.main.async {
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                //}
            })
        
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        // 2. Observable로 생기는 데이터를 받아서 처리하는 방법
    }
}

