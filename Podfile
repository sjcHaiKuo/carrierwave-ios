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

# Exclusive demo dependencies
target 'Demo' do link_with 'Carrierwave Demo'
  pod 'AFNetworking', '~> 2.5'
end

# Exclusive test dependencies
target 'Tests' do link_with 'Unit Tests'
  pod 'Expecta', configuration: 'Test'
  pod 'OCMock', '~> 2.0.1', configuration: 'Test'
  pod 'OCMockito', '~> 1.4', configuration: 'Test'
  pod 'OHHTTPStubs', configuration: 'Test'
  pod 'Specta-Taptera', git: 'https://github.com/taptera/specta', branch: 'taptera-action', configuration: 'Test'
end
