## FantorangenTV für Elise ##

I got tired of selecting and playing the episodes of Fantorangen in the NRK TV app so I wrote an app to play all of them through.

The dependencies in this project are managed via [Cocoapods][0].

The main goal of the app will be to display and allow the playback of individual episodes or the entire playlist sequentially or randomly.

The basis of the AVPlayer code is the [AVPlayerDemo][1] from Apple. The original did not support ARC and generally needs a lot of massaging to make it reusable.The goals for the AVPlayer work will be to provide background Airplay support, Skip forward, backward, scrub through the video and provide some polish in the form of graphical assets. I'll ultimately put this out as a standalone Cocoapod.

[0]: http://cocoapods.org
[1]: https://developer.apple.com/library/ios/samplecode/AVPlayerDemo/Introduction/Intro.html
