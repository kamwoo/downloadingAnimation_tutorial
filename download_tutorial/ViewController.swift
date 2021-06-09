//
//  ViewController.swift
//  download_tutorial
//
//  Created by wooyeong kam on 2021/06/09.
//

import UIKit
import Loady
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var myDownLoadBtn: LoadyButton!
    
    @IBOutlet var myBtns : [LoadyButton]!
    @IBOutlet weak var uberLikeBtn: LoadyButton!
    @IBOutlet weak var fourPhaseBtn: LoadyFourPhaseButton!
    @IBOutlet weak var downLoadingBtn: LoadyButton!
    @IBOutlet weak var indicatorBtn: LoadyButton!
    @IBOutlet weak var androidBtn: LoadyButton!
    @IBOutlet weak var fillingBtn: LoadyButton!
    @IBOutlet weak var CircleBtn: LoadyButton!
    @IBOutlet weak var appstoreBtn: LoadyButton!
    
    
    
    override func loadView() {
        super.loadView()
        myDownLoadBtn.layer.cornerRadius = 20
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 에니메이션 설정
        myDownLoadBtn.setAnimation(LoadyAnimationType.backgroundHighlighter())
        myDownLoadBtn.backgroundFillColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        myDownLoadBtn.layer.cornerRadius = 20
        
        myDownLoadBtn.addTarget(self, action: #selector(onBtnClicked(sender:)), for: .touchUpInside)
        
        //
        uberLikeBtn.setAnimation(LoadyAnimationType.topLine())
        
        //
        fourPhaseBtn.loadingColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        let normalPhase = (title : "대기중", image: UIImage(systemName: "stopwatch"), background: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        let loadingPhase = (title : "진행 중 ....", image: UIImage(systemName: "paperplane.fill")?.withTintColor(.white).withRenderingMode(.alwaysOriginal), background: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
        let successPhase = (title : "다운로드 완료", image: UIImage(systemName: "checkmark.circle.fill"), background: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
        let errorPhase = (title : "다운로드 실패", image: UIImage(systemName: "flag.fill"), background: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        fourPhaseBtn.setPhases(phases: .init(normalPhase: normalPhase, loadingPhase: loadingPhase, successPhase: successPhase, errorPhase: errorPhase))
        
        //
        let downloadingLabel = (title: "다운로드 중입니다....", font: UIFont.boldSystemFont(ofSize: 10), textColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
        let percentageLabel = (font: UIFont.boldSystemFont(ofSize: 10), textColor: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
        let downloadedLabel = (title: "다운로드 완료", font: UIFont.boldSystemFont(ofSize: 10), textColor: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
        
        downLoadingBtn.setAnimation(LoadyAnimationType.downloading(with: .init(downloadingLabel: downloadingLabel, percentageLabel: percentageLabel, downloadedLabel: downloadedLabel)))
        downLoadingBtn.backgroundFillColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        
        //
        indicatorBtn.setAnimation(LoadyAnimationType.indicator(with: .init(indicatorViewStyle: .light)))
        
        //
        androidBtn.setAnimation(LoadyAnimationType.android())
        androidBtn.backgroundFillColor = .blue
        androidBtn.loadingColor = .red
        
        //
        fillingBtn.setAnimation(LoadyAnimationType.backgroundHighlighter())
        fillingBtn.backgroundFillColor = .black
        
        //
        CircleBtn.setAnimation(LoadyAnimationType.circleAndTick())
        CircleBtn.loadingColor = .blue
        CircleBtn.backgroundColor = .yellow
        
        //
        appstoreBtn.setAnimation(LoadyAnimationType.appstore(with: .init(shrinkFrom: .fromLeft)))
        appstoreBtn.pauseImage = UIImage(systemName: "pause")?.withTintColor(.white).withRenderingMode(.alwaysOriginal)
        appstoreBtn.backgroundFillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        myBtns.forEach{ (btnItem : LoadyButton) in
            btnItem.layer.cornerRadius = 10
            btnItem.addTarget(self, action: #selector(onBtnClicked(sender:)), for: .touchUpInside)
        }
    }
    
    
    @objc fileprivate func onBtnClicked(sender : LoadyButton){
        print("ViewController - onBtnClicked() called")
        
        
        sender.stopLoading()
        // 들어온 버튼 설정
        sender.startLoading()
        
        if let button = sender as? LoadyFourPhaseButton {
            button.loadingPhase()
        }
        
        let downloadApiUrl =  "http://ipv4.download.thinkbroadband.com/0.5MB.zip"
        
        let progressQueue = DispatchQueue(label: "com.downloadBtn_tutorial.progressQueue", qos: .utility)
        
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            // 파일 확장자 붙이기
//            let fileURL = documentsURL.appendingPathComponent("image.png")
            
            // removePreviousFile : 해당 경로에 파일있으면 지우기, createIntermediateDirectories: 중간 폴더 만들기
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download(downloadApiUrl, to: destination)
            .downloadProgress(queue: progressQueue) { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                    
                    let loadingPercent = progress.fractionCompleted * 100
                    
                    
                    DispatchQueue.main.async {
                        sender.update(percent: CGFloat(loadingPercent))
                    }
                
                }
            .response { response in
            debugPrint(response)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    sender.stopLoading()
                    if let button = sender as? LoadyFourPhaseButton {
                        button.successPhase()
                    }
                }

//            if response.error == nil, let imagePath = response.fileURL?.path {
//                let image = UIImage(contentsOfFile: imagePath)
//            }
        }
    }


}

