# ``GameKitSwiftUI``

`GameKitSwiftUI` provides support for using **GameKit** with **SwiftUI**. This package is a customized version of awesome [GameKitUI](https://github.com/SwiftPackageRepository/GameKitUI.swift) by Sascha Muellner with added support for view customization and **DocC Documentation**.

Additionally, it has been updated to use the latest versions of **Swift** and the support for the latest Apple OS versions. A fix has also been provided for a bug where **GameCenter Authentication** could fail leaving the `GKAuthenticationView` displayed forever.

## Overview

`GameKitSwiftUI` provides access to the following GameKit features in **SwiftUI**:

* **Authentication** - By using `GKAuthentication` and `GKAuthenticationView`, you can easily support `GKLocalPlayer` authentication in SwiftUI.
* **Invite** - Invites created by a **GameKit MatchMaker** or **TurnBasedMatchmaker** can be handled using a `GKInviteView`. 
* **Matchmaking** - Match making for a live match can be initiated via the `GKMatchMakerView`. To start a turn-based match use `GKTurnBasedMatchmakerView`
* **State Changes** -`GameKitSwiftUI` views rely on a `GKMatchManager` manager singleton, which listens to **GameKit** state changes of the match-making process.

### GameCenter Authentication

To authenticate the player with GameCenter just show the authentication view **GKAuthenticationView**. 

```swift
import SwiftUI
import GameKitSwiftUI

struct ContentView: View {
    @State private var enableGameCenter = true
    
    var body: some View {
        ...
        
        // Check for Game Center Authentication
       if enableGameCenter { 
            GKAuthenticationView(
            failed: { (error) in
                print("Failed: \(error.localizedDescription)")
                enableGameCenter = false
            },
            authenticated: { (playerName) in
                print("Hello \(playerName)")
                enableGameCenter = false
            })
        }
    }
}
```

The following parameters can be added to `GKAuthenticationView` to adjust its appearance:

* `showLoading` - Shows or hides the loading progress indicator.
* `spinnerStyle` - Sets the progress indicator style as `medium` or `large`
* `spinnerColor` - Sets the progress indicator color.
* `backgroundColor` - Sets the background color of the panel that convert the view while the authentication occurs.

> **NOTE:** In some instances `GKLocalPlayer` can fail to authenticate and the `GKAuthenticationView` can get stuck being shown. If `GameKitSwiftUI` is unable to verify authentication after 10 seconds, an error will be sent to the `failed` property and the view will be closed.

### GameKit Invite

Invites created by a **GameKit MatchMaker** or **TurnBasedMatchmaker** can be handled using a `GKInviteView`:

```swift
import SwiftUI
import GameKitUI

struct ContentView: View {
    var body: some View {
        GKInviteView(
            invite: GKInvite()
        ) {
        } failed: { (error) in
            print("Invitation Failed: \(error.localizedDescription)")
        } started: { (match) in
            print("Match Started")
        }
    }
}
```

#### GameKit MatchMaker

Match making for a live match can be initiated via the `GKMatchMakerView`. 

```swift
import SwiftUI
import GameKitUI

struct ContentView: View {
    var body: some View {
        GKMatchMakerView(
                    minPlayers: 2,
                    maxPlayers: 4,
                    inviteMessage: "Let us play together!"
                ) {
                    print("Player Canceled")
                } failed: { (error) in
                    print("Match Making Failed: \(error.localizedDescription)")
                } started: { (match) in
                    print("Match Started")
                }
    }
}
```

#### GameKit TurnBasedMatchmaker

To start a turn-based match use `GKTurnBasedMatchmakerView`:

```swift
import SwiftUI
import GameKitUI

struct ContentView: View {
    var body: some View {
        GKTurnBasedMatchmakerView(
                    minPlayers: 2,
                    maxPlayers: 4,
                    inviteMessage: "Let us play together!"
                ) {
                    print("Player Canceled")
                } failed: { (error) in
                    print("Match Making Failed: \(error.localizedDescription)")
                } started: { (match) in
                    print("Match Started")
                }
    }
}
```

### GameKit Manager

GameKitUI views rely on a `GKMatchManager` manager singleton, which listens to **GameKit** state changes of the match-making process. Changes to the local player (`GKLocalPlayer`), invites (`GKInvite`) or matches (`GKMatch`) can be observed using the provided public subjects `CurrentValueSubject`:

```swift
import SwiftUI
import GameKitUI

class ViewModel: ObservableObject {

    @Published public var gkInvite: GKInvite?
    @Published public var gkMatch: GKMatch?

    private var cancellableInvite: AnyCancellable?
    private var cancellableMatch: AnyCancellable?
    private var cancellableLocalPlayer: AnyCancellable?

    public init() {
        self.cancellableInvite = GKMatchManager
            .shared
            .invite
            .sink { (invite) in
                self.gkInvite = invite.gkInvite
        }
        self.cancellableMatch = GKMatchManager
            .shared
            .match
            .sink { (match) in
                self.gkMatch = match.gkMatch
        }
        self.cancellableLocalPlayer = GKMatchManager
            .shared
            .localPlayer
            .sink { (localPlayer) in
                // current GKLocalPlayer.local
        }
    }
    
    deinit() {
        self.cancellableInvite?.cancel()
        self.cancellableMatch?.cancel()
        self.cancellableLocalPlayer?.cancel()
    }
}
```

# Examples

For further examples and documentation, please see Sascha Muellner's original [GameKitUI](https://github.com/SwiftPackageRepository/GameKitUI.swift) Swift Package on GitHub.
