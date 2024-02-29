# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
          end
   end
end


target 'indogo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for indogo
  
pod 'SwiftyJSON', '~> 4.0'
pod 'Alamofire', '~> 4.7'
pod 'AlamofireImage'
pod 'Kingfisher', '~> 4.8.1'
pod 'FSPagerView'
pod 'ImageSlideshow', '~> 1.7.0'
pod 'ImageSlideshow/Kingfisher'
pod "KingfisherWebP"
pod 'iProgressHUD', '~> 1.1.1'
pod 'PKHUD'
pod 'QRCodeReader.swift'
pod 'SwiftSignatureView', '~> 3.0'
pod 'RSBarcodes_Swift', '~> 5.0.2'
pod 'ProgressHUD'
pod "ZKProgressHUD"
pod 'CryptoSwift'
pod 'FirebaseCore'
pod 'FirebaseMessaging'
pod 'FirebaseAnalytics'

end
