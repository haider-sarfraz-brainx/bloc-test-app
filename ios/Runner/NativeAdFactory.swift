import Foundation
import google_mobile_ads
import UIKit

class NativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]?) -> NativeAdView {
    guard let nibObjects = Bundle.main.loadNibNamed("listTileMedium", owner: nil, options: nil),
          let adView = nibObjects.first as? NativeAdView else {
      fatalError("Could not load nib file for native ad view")
    }

    (adView.headlineView as? UILabel)?.text = nativeAd.headline
    (adView.bodyView as? UILabel)?.text = nativeAd.body
    adView.bodyView?.isHidden = nativeAd.body == nil

    (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    adView.callToActionView?.isHidden = nativeAd.callToAction == nil

    (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    adView.iconView?.isHidden = nativeAd.icon == nil

    (adView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    adView.advertiserView?.isHidden = nativeAd.advertiser == nil

    adView.nativeAd = nativeAd

    return adView
  }
}
