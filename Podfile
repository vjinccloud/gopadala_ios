# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

post_install do |installer|
    xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # For xcode 15+ only
             if config.base_configuration_reference && Integer(xcode_base_version) >= 15
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end


target 'Gopadala' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Gopadala
  
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
