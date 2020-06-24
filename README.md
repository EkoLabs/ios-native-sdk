# ios-native-sdk
A lightweight SDK that allows for easy integration of eko projects into an iOS app

# API
## EkoPlayerView
This is the view in which the eko player will reside. It will also forward any events from the player to the rest of the app.
### Properties
#### delegate : EkoPlayerViewDelegate
See [EkoPlayerViewDelegate](#ekoplayerviewdelegate) for more information
#### urlDelegate: EkoUrlDelegate
optional. If no delegate is set, urls will be opened in the default browser.
See [EkoUrlDelegate](#ekourldelegate) for more information
#### shareDelegate: EkoShareDelegate
optional. If no delegate is set, urls will be shared via the native iOS share dialog.
See [EkoShareDelegate](#ekosharedelegate) for more information
#### appName: String
App name is for analytics purposes. Will default to the bundle id if not set. Warning: setting this property will reset the entire webview.
### Methods
#### init()
The EkoPlayerView can be initialized programmatically or included via storyboard.
#### load(projectId: String, options: EkoOptions)
Will load and display an eko project. The EkoPlayerView will display the loading animation while it prepares the project for playback.

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| projectId | `String` | The id of a project to display |
| options | `EkoOptions` | Options for project delivery. See [EkoOptions](#ekooptions) for more details. |

#### play()
Will attempt to begin playing an eko project. Any errors will be reported via the EkoPlayerViewDelegate. Errors could occur if you attempt to call play before the player is ready.
#### pause()
Will attempt to pause an eko project. Any errors will be reported via the EkoPlayerViewDelegate. Errors could occur if you attempt to call pause before the player is ready.
#### invoke(method: String, args: [Any], errorHandler: @escaping (Error) -> Swift.Void)
Will call any player function defined on the developer site and return the response via callback function.

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| method | `String` | The player method to call. |
| args | `[Any]` | Any arguments that should be passed into the method (must be serializable to json) |
| errorHandler | `Function` | Error handler. |

## EkoPlayerViewDelegate
This is a protocol that the app should implement. Events and other information will be passed to the app from the SDK via the delegate.
### Methods
#### onEvent(event:String, args: [Any])
The eko player triggers a number of events. The app can listen to these events by providing the event name in the load call. This function will be called whenever an event passed in to `load()` is triggered.

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| event | `String` | The name of the event fired. |
| args | `[Any]` | Any arguments that might have been passed along when the event was fired. |

#### onError(error: Error)
Called whenever an error occurs. This could happen in the loading process (if an invalid project id was given or we fail to open the link to the project), or if an event is passed in with malformed data (missing an event name, etc).

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| error | `Error` | An error with a description of the issue. |

## EkoUrlDelegate
Delegate for link out events..
### Methods
#### onUrlOpen(url: String)
There can be link outs from within an eko project. This function will be called whenever a link out is supposed to occur. The delegate is responsible for opening the url.

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| url | `String` | The url to open. |

## EkoShareDelegate
Delegate for share events.
### Methods
#### onShare(url: String)
There can be share intents from within an eko project via share buttons or ekoshell. This function will be called whenever a share intent happened.

| Param           | Type           | Description  |
| :-------------: |:--------------:| :------------|
| url | `String` | The canonical url of the project. |

## EkoOptions
### Properties
#### params: Map<String, String> = { “autoplay”: "true" }
A list of embed params that will affect the delivery.
#### events: String[] = []
A list of events that should be forwarded to the app
#### showCover: Boolean = true
Will the SDK show a cover while loading
#### customCover: UIView?
A custom view to display instead of the default one

# Default Player Events
#### eko.canplay
Triggered when the player has buffered enough media to begin playback. Only added if `showCover=true` and `autoplay=false`
#### eko.playing
Only added if `showCover=true` and `autoplay=true`

# Additional Notes
Please note this is a static framework. If you would like to use the dynamic version, please download the repo, and change `MACH_O_TYPE` to  `dynamiclib` and rebuild. The storyboard compatibility is only available with the dynamic framework.

