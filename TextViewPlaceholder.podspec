Pod::Spec.new do |spec|

  spec.name         = "TextViewPlaceholder"
  spec.version      = "1.0"
  spec.summary      = "A library to add placeholder for UITextView"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/LaptrinhvaCuocsong/TextViewPlaceholder"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "hungnm" => "nguyenmanhhung131298@gmail.com" }

  spec.ios.deployment_target = "12.1"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/LaptrinhvaCuocsong/TextViewPlaceholder.git", :tag => "v#{spec.version}" }
  spec.source_files  = "TextViewPlaceholder/*.{h,m,swift}"

end
