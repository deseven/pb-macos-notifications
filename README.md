# pb-osx-notifications
Native OS X notifications for [PureBasic](http://purebasic.com).  

## notice
You **HAVE TO** build correct application bundle with a valid bundle identifier.  
You also **HAVE TO** sign your bundle with a valid developer signature.  
Alternatively you can use external tool called [terminal-notifier](https://github.com/julienXX/terminal-notifier).  

## usage
```
IncludeFile "notifications.pbi"  
notifications::init()  
Define notification.notifications::osxNotification
notification\title = "Test Title"  
notification\subTitle = "Test Subtitle"  
...  
notifications::sendNotification(@notification)
```