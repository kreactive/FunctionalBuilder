#
# Be sure to run `pod lib lint FunctionalBuilder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FunctionalBuilder"
  s.version          = "0.1.0"
  s.summary          = "Compose generic functions and accumulate errors"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Compose generic functions, accumulate errors and return the result as a tuple
                       DESC

  s.homepage         = "https://github.com/kreactive/FunctionalBuilder"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Antoine Palazzolo" => "a.palazzolo@kreactive.com" }
  s.source           = { :git => "https://github.com/kreactive/FunctionalBuilder.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Antoine_p'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'FunctionalBuilder/*'
  s.prepare_command = <<-CMD
  printenv
/usr/bin/env xcrun --sdk macosx swift "FunctionalBuilder/builder/main.swift" -composeCount 10 -targetFile "FunctionalBuilder/Composers.swift" -templateDirectory "FunctionalBuilder/builder"
                     CMD
end
