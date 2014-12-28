#
#  Carrierwave.podspec
#
#  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
#

Pod::Spec.new do |spec|

  spec.name          = 'Carrierwave'
  spec.summary       = 'Lightweight Carrierwave client for iOS'

  spec.homepage      = 'https://github.com/netguru/carrierwave-ios'
  spec.license       = { :type => 'MIT', :file => 'LICENSE.md' }

  spec.authors       = {
                         'Adrian Kashivskyy' => 'adrian.kashivskyy@netguru.pl',
                         'Patryk Kaczmarek' => 'patryk.kaczmarek@netguru.pl',
                         'Wojciech Trzasko' => 'wojciech.trzasko@netguru.pl',
                       }

  spec.version       = '0.1.0'
  spec.source        = { :git => 'https://github.com/netguru/carrierwave-ios.git', :tag => spec.version.to_s }
  spec.platform      = :ios, '8.0'

  spec.source_files  = 'Carrierwave/**/*.{h,m}'
  spec.requires_arc  = true

  spec.frameworks    = 'MobileCoreServices', 'UIKit'

  spec.dependency      'AFNetworking', '~> 2.5'

end
