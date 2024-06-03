//
//  ViewController.swift
//  ThumbnailSliderView
//
//  Created by ayumu.nishimura on 2024/05/27.
//

import UIKit

class ThumbnailSliderView: UIView, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private let collectionViewLayout = ThumbnailCollectionViewFlowLayout()
    private let viewHeight: CGFloat = 120.0
    private let cellScale: CGFloat = 0.8
    private var thumbnails = [UIImage]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbnails = [
            UIImage(named: "Image 1")!,
            UIImage(named: "Image 2")!,
            UIImage(named: "Image 3")!,
            UIImage(named: "Image 4")!,
            UIImage(named: "Image 5")!,
            UIImage(named: "Image 6")!,
            UIImage(named: "Image 7")!,
            UIImage(named: "Image 8")!,
            UIImage(named: "Image 9")!,
            UIImage(named: "Image 10")!,
            UIImage(named: "Image 11")!,
            UIImage(named: "Image 12")!,
            UIImage(named: "Image 13")!,
            UIImage(named: "Image 14")!,
        ]

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.addSubview(collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: viewHeight),
            collectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])


        // 画面中央にサムネイルが表示されるようにする（レイアウト完了前に調整する必要があるためセルのサイズ計算をする）
        let cellHeight = viewHeight * cellScale

        let firstImageSize = thumbnails.first?.size ?? .zero
        let firstCellScale = cellHeight / firstImageSize.height
        let firstCellSize = CGSize(width: firstImageSize.width * firstCellScale, height: cellHeight)
        let leftMargin = (frame.width - firstCellSize.width) / 2

        let lastImageSize = thumbnails.last?.size ?? .zero
        let lastCellScale = cellHeight / lastImageSize.height
        let lastCellSize = CGSize(width: lastImageSize.width * lastCellScale, height: cellHeight)
        let rightMargin = (frame.width - lastCellSize.width) / 2

        collectionView.contentInset = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: rightMargin)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 初期表示の調整に必要
        collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDataSource
extension ThumbnailSliderView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThumbnailCell
        cell.thumbnailImage.image = thumbnails[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Cellが拡大表示されても
        let cellHeight = collectionView.frame.height * cellScale
        let pageSize = thumbnails[indexPath.row].size
        let scale = cellHeight / max(pageSize.height, 1)
        return CGSize(width: pageSize.width * scale, height: cellHeight)
    }
}

// MARK: - ThumbnailCell, ThumbnailCollectionViewFlowLayout
extension ThumbnailSliderView {

    class ThumbnailCell: UICollectionViewCell {
        let thumbnailImage = UIImageView(image: nil)

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(thumbnailImage)
            thumbnailImage.frame = contentView.bounds
            thumbnailImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ThumbnailCollectionViewFlowLayout: UICollectionViewFlowLayout {

        override init() {
            super.init()
            scrollDirection = .horizontal
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// 指定された矩形内のすべてのセルとビューのレイアウト属性を取得する。
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let collectionView, let rectAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
            var cellWidthDifference = 0.0

            // セルが画面中央に近づくにつれ拡大表示させる
            for attribute in rectAttributes where attribute.frame.intersects(visibleRect) {
                // 1.画面中央からどれだけセルが離れているかを計算
                let distanceFromCenter = visibleRect.midX - attribute.center.x
                // 2.拡大縮小を始める範囲を決定
                let maxDistance = attribute.frame.width / 2

                // 3.セルが拡大縮小の範囲内に入っているかを判定
                if abs(distanceFromCenter) < maxDistance {
                    // 4.拡大縮小の倍率を計算
                    let originCellWidth = attribute.frame.width                                 // 元々のセル幅
                    let cellHeightRatio = collectionView.frame.height / attribute.frame.height  // CollectionViewに対するセルの高さ比率を計算
                    let distanceRatio   = distanceFromCenter / maxDistance                      // 画面中央からセルまでの距離比率を計算
                    let zoomScale       = 1 + (cellHeightRatio - 1) * (1 - abs(distanceRatio))  // ズーム倍率を計算
                    // 5.拡大縮小を適用
                    attribute.transform3D = CATransform3DMakeScale(zoomScale, zoomScale, 1)

                    // 6.次のセル間隔調整のためにセル幅の変化量を保持
                    cellWidthDifference = attribute.frame.width - originCellWidth
                }
            }

            // セルの拡大に合わせて、左右のセル間隔を調整する
            for attribute in rectAttributes where attribute.frame.intersects(visibleRect) {
                // 1.画面中央からどれだけセルが離れているかを計算
                let distanceFromCenter = visibleRect.midX - attribute.center.x
                // 2.拡大縮小を始める範囲を決定
                let maxDistance = attribute.frame.width / 2

                // 3.セルが拡大縮小の範囲外か判定
                if abs(distanceFromCenter) > maxDistance {
                    // 4.セルが左右のどちらにあるかを判定
                    if distanceFromCenter > 0 {
                        // 5.左の場合、拡大縮小したセルの幅分だけセルを左にずらす
                        attribute.frame.origin.x -= (cellWidthDifference / 2)
                    } else {
                        // 5.右の場合、拡大縮小したセルの幅分だけセルを右にずらす
                        attribute.frame.origin.x += (cellWidthDifference / 2)
                    }
                }
            }

            return rectAttributes
        }

        /// スクロールを停止するポイントを取得します。
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            // 1. スクロール完了地点に表示される、セルのレイアウト属性を取得
            guard let collectionView,
                  let layoutAttributes = super.layoutAttributesForElements(in: CGRect(origin: proposedContentOffset, size: collectionView.frame.size))
            else { return proposedContentOffset }

            // 2.「スクロール完了地点 + 画面幅の半分」でスクロール完了時の画面中央のポイントを計算
            let horizontalCenter = proposedContentOffset.x + (collectionView.frame.width / 2)

            // 3. 画面中央に最も近いセルが、中央（2の数値）からどれだけ離れているかを保持する変数
            var closestOffset = CGFloat.greatestFiniteMagnitude

            // 4. レイアウト属性を一つずつ確認
            for attribute in layoutAttributes {
                // 5. 各セルの中央と画面中央の距離を計算
                let distanceFromCenter = attribute.center.x - horizontalCenter
                // 6. 画面中央に最も近いセルとの距離を更新
                if abs(distanceFromCenter) < abs(closestOffset) {
                    closestOffset = distanceFromCenter
                }
            }

            // 7. スクロール停止地点のx座標を「スクロール停止地点 + 3の変数」にすることで画面中央に近いセルを中央に表示させる
            return CGPoint(x: proposedContentOffset.x + closestOffset, y: proposedContentOffset.y)
        }

        // boundsが変更されたらレイアウトを更新するかの設定
        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            // セルの拡大縮小などのレイアウト変更が更新されるようにtrueを返します
            return true
        }
    }
}
