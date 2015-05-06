#
#  Podfile
#
#  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
#

# Pod sources
source 'https://github.com/CocoaPods/Specs.git'

# Initial configuration
platform :ios, '8.0'
inhibit_all_warnings!
xcodeproj 'Carrierwave', 'Development' => :debug, 'Production' => :release, 'Staging' => :release, 'Test' => :debug

# Global project dependencies
pod 'AFNetworking', '~> 2.5'
pod 'NGRCrop', :git => 'git@github.com:netguru/ngrcrop-ios.git'

# Exclusive demo dependencies
target 'Demo' do
    link_with 'Carrierwave Demo'
end

# Exclusive test dependencies
target 'Tests' do
    link_with 'Unit Tests', 'Functional Tests'
    
    pod 'Expecta'
    pod 'KIF'
    pod 'OCMock'
    pod 'OHHTTPStubs'
    pod 'Specta', git: 'https://github.com/specta/specta.git', tag: 'v0.3.0.beta1'
end
