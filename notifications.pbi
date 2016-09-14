; pb-osx-notifications rev.1
; written by deseven
; won't be possible without wilbert's help :)
; http://forums.purebasic.com/english/viewtopic.php?f=19&t=64945
;
; https://github.com/deseven/pb-osx-notifications

; !!! ATTENTION !!!
; you HAVE TO to build correct application bundle with a valid bundle identifier
; you also HAVE TO to sign your bundle with a valid developer signature
; alternatively you can use external tool called terminal-notifier:
; https://github.com/julienXX/terminal-notifier

DeclareModule notifications
  
  Structure osxNotification
    title.s
    subTitle.s
    text.s
    alwaysShow.b
    deleteAfterClick.b
    event.i
    evWindow.i
    evObject.i
    evType.i
    evData.i
  EndStructure
  
  Declare.b init()
  Declare.b sendNotification(*notification.osxNotification)
  
EndDeclareModule

Module notifications
  
  Define notificationCenter.i
  Define app.i
  
  ProcedureC didActivateNotification(obj,sel,center,notification)
    Shared notificationCenter
    Protected.i deleteAfterClick,event,evWindow,evObject,evType,evData
    Protected options.i = CocoaMessage(0,notification,"userInfo")
    deleteAfterClick = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"deleteAfterClick"),"intValue")
    If deleteAfterClick
      CocoaMessage(0,notificationCenter,"removeDeliveredNotification:",notification)
    EndIf
    event = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"event"),"intValue")
    evWindow = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"evWindow"),"intValue")
    evObject = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"evObject"),"intValue")
    evType = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"evType"),"intValue")
    evData = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"evData"),"intValue")
    If event
      If evWindow Or evObject Or evType Or evData
        PostEvent(event,evWindow,evObject,evType,evData)
      Else
        PostEvent(event)
      EndIf
    EndIf
  EndProcedure
  
  ProcedureC shouldPresentNotification(obj,sel,center,notification)
    Protected options.i = CocoaMessage(0,notification,"userInfo")
    Protected alwaysShow.i = CocoaMessage(0,CocoaMessage(0,options,"objectForKey:$",@"alwaysShow"),"intValue")
    If alwaysShow
      ProcedureReturn #YES
    Else
      ProcedureReturn #NO
    EndIf
  EndProcedure
  
  Procedure.b init()
    Shared notificationCenter.i,app.i
    Protected delegateClass = objc_allocateClassPair_(objc_getClass_("NSObject"),"myDelegateClass",0)
    class_addMethod_(delegateClass,sel_registerName_("userNotificationCenter:didActivateNotification:"),@didActivateNotification(),"v@:@@")
    class_addMethod_(delegateClass,sel_registerName_("userNotificationCenter:shouldPresentNotification:"),@shouldPresentNotification(),"c@:@@") 
    objc_registerClassPair_(delegateClass)
    Protected delegate = class_createInstance_(delegateClass,0)
    notificationCenter = CocoaMessage(0,0,"NSUserNotificationCenter defaultUserNotificationCenter")
    CocoaMessage(0,notificationCenter,"setDelegate:",delegate)
    app = CocoaMessage(0,0,"NSApplication sharedApplication")
    ProcedureReturn #True
  EndProcedure
  
  Procedure.b sendNotification(*notification.osxNotification)
    Shared notificationCenter.i
    Protected keys.i,values.i,options.i
    Protected notification = CocoaMessage(0,0,"NSUserNotification new")
    If notificationCenter And notification And *notification
      
      ; setting notification title and other params
      If Len(*notification\title) : CocoaMessage(0,notification,"setTitle:$",@*notification\title) : EndIf
      If Len(*notification\subTitle) : CocoaMessage(0,notification,"setSubtitle:$",@*notification\subTitle) : EndIf
      If Len(*notification\text) : CocoaMessage(0,notification,"setInformativeText:$",@*notification\text) : EndIf
      CocoaMessage(0,notification,"setHasActionButton:",#NO)
      
      ; building options list
      ; we will need it in callbacks to decide what to do
      CocoaMessage(@keys,0,"NSArray arrayWithObject:$",@"alwaysShow")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"deleteAfterClick")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"event")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"evWindow")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"evObject")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"evType")
      CocoaMessage(@keys,keys,"arrayByAddingObject:$" ,@"evData")
      CocoaMessage(@values,0,"NSArray arrayWithObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:", *notification\alwaysShow))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\deleteAfterClick))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\event))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\evWindow))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\evObject))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\evType))
      CocoaMessage(@values,values,"arrayByAddingObject:",CocoaMessage(0,0,"NSNumber numberWithInteger:",*notification\evData))
      CocoaMessage(@options,0,"NSDictionary dictionaryWithObjects:",values,"forKeys:",keys)
      CocoaMessage(0,notification,"setUserInfo:",options)
      
      If CocoaMessage(0,notificationCenter,"deliverNotification:",notification)
        ProcedureReturn #True
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; Folding = --
; EnableUnicode
; EnableXP