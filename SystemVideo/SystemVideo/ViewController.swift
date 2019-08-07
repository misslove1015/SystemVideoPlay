//
//  ViewController.swift
//  SystemVideo
//
//  Created by 郭明亮 on 2019/7/19.
//  Copyright © 2019 郭明亮. All rights reserved.
//

import UIKit
import AVFoundation

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let path:String = Bundle.main.path(forResource: "IMG_8663", ofType: "MOV")!

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var player:AVPlayer! // 播放器
    var playerItem:AVPlayerItem! // 播放 Item
    var playerLayer:AVPlayerLayer! // 播放 lLayer
    var collectionView:ImageCollectionView! // 预览图 CollectionView
    var dataArray:[UIImage]! = [] // 预览图数组
    var totalDuration:Double! // 视频时长
    var timeLabel:UILabel! // 播放时间
    var totalWidth:Float = 0 // 预览图总宽度
    var playTimeObserver:Any! // 播放时间监听
    var isDragging = false // 是否在拖动 CollectionView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPage()
        
        getScreenShotImages()
        initPlayer()
    }
    
    deinit {
        player.pause()
        player.removeTimeObserver(playTimeObserver as Any)
    }
    
    // MARK: - scrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
        self.player.pause()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isDragging == false {return}
        isDragging = false
        self.player.play()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if isDragging == false {return}
            isDragging = false
            self.player.play()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isDragging {return}
        let time = Float(scrollView.contentOffset.x) / totalWidth * Float(totalDuration)
        timeLabel.text = strWithTime(time: time)
        player.seek(to: CMTime(value: CMTimeValue(time), timescale: 1))
    }
    
    func strWithTime(time: Float) -> String {
        var time = time
        if time < 0 {time = 0}
        if time > Float(totalDuration) {time = Float(totalDuration)}
        return String(format: "%02li:%02li", lround(Double(floor(time/60.0))), lround(Double(floor(time/1.0)))%60)
    }
    
    // MARK: - 获取预览图
    func getScreenShotImages() {
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        totalDuration = CMTimeGetSeconds(asset.duration)
        var count = 0
        if totalDuration < 10 {
            count = 3
        }else if totalDuration < 60 {
            count = 7;
        }else {
            count = 10 * (Int(totalDuration) / 60);
        }
        
        for i in 0..<count {
            let second = totalDuration * (Double(i) / Double(count))
            guard let image = getVideoThumbnail(asset: asset, second: CGFloat(second)) else {return}
            dataArray.append(image)
        }
        totalWidth = Float(dataArray.count) * (50*16/9.0)
        collectionView.reloadData()
    }
    
    func getVideoThumbnail(asset: AVAsset, second: CGFloat) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(second), preferredTimescale: 10)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        let imageRef:CGImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        let frameImg = UIImage(cgImage: imageRef)
        guard let image = compressImage(with: frameImg) else {return nil}
        return image
    }
    
    func compressImage(with image: UIImage) -> UIImage? {
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let width = imageWidth < 150 ? imageWidth : 150
        let height = Float((image.size.height) / ((image.size.width) / CGFloat(width)))
        let widthScale = imageWidth / width
        let heightScale = imageHeight / height
        UIGraphicsBeginImageContext(CGSize(width: CGFloat(width), height: CGFloat(height)))
        if widthScale > heightScale {
            image.draw(in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth / heightScale), height: CGFloat(height)))
        } else {
            image.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(imageHeight / widthScale)))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    // MARK: - 设置播放器
    func initPlayer() {
        let videoView = UIView(frame: CGRect(x: 0, y: 60, width: screenWidth, height: screenHeight-60-50-30))
        self.view.addSubview(videoView)
        
        playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        addTimeObserver()
        
    }
    
    func addTimeObserver() {
        playTimeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main) { (time) in
            if self.isDragging {return}
            let playTime = Float(CMTimeGetSeconds(time))
            self.timeLabel.text = self.strWithTime(time: playTime)
            let x = CGFloat(playTime/Float(self.totalDuration)*self.totalWidth)
            self.collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }
    }
    
    // MARK: - CollectionViewDelgateDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        cell.imageView.image = self.dataArray[indexPath.item]
        return cell
    }

    // MARK: - 初始化页面
    func initPage() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: screenWidth/2.0, bottom: 0, right: screenWidth/2.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 50*16/9.0, height: 50)
        layout.scrollDirection = .horizontal
        collectionView = ImageCollectionView(frame: CGRect(x: 0, y: screenHeight-30-50, width: screenWidth, height: 50), collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(collectionView)
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: collectionView.frame.origin.y-25, width: screenWidth, height: 25))
        timeLabel.textAlignment = .center
        timeLabel.text = "00:00"
        timeLabel.font = .systemFont(ofSize: 12)
        self.view.addSubview(timeLabel)
        
        let view = UIView(frame: CGRect(x: screenWidth/2, y: collectionView.frame.origin.y, width: 1, height: 50))
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        collectionView.touchBegin = { [weak self] in
            self?.isDragging = true
            self?.player.pause()
        }
        
        collectionView.touchEnd = { [weak self] in
            self?.isDragging = false
            self?.player.play()
        }
    }
    
}

