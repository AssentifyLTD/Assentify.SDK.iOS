
import Foundation

@objc public enum FaceEvents:Int {
   case ROLL_LEFT
   case ROLL_RIGHT
   case YAW_LEFT
   case YAW_RIGHT
   case PITCH_UP
   case PITCH_DOWN
   case GOOD
   case WINK
   case WINK_LEFT
   case WINK_RIGHT
   case NO_DETECT
    
}


@objc public enum ActiveLiveEvents: Int, CaseIterable {
    case YAW_LEFT
    case YAW_RIGHT
    case PITCH_UP
    case PITCH_DOWN
    case WINK
    case WINK_LEFT
    case WINK_RIGHT
    case GOOD
    
}


@objc public enum ActiveLiveType: Int, CaseIterable {
    case ACTIONS
    case WINK
    case NON
}



func getRandomEvents(activeLiveType: ActiveLiveType) -> Set<ActiveLiveEvents> {
    let allEvents = getFilteredEventsByType(type: activeLiveType)
    var randomEvents = Set<ActiveLiveEvents>()
    
    while randomEvents.count < 3 && randomEvents.count < allEvents.count {
        if let randomEvent = allEvents.randomElement() {
            randomEvents.insert(randomEvent)
        }
    }
    
    return randomEvents
}

func getFilteredEventsByType(type: ActiveLiveType) -> [ActiveLiveEvents] {
    switch type {
    case .ACTIONS:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD &&
            $0 != .WINK &&
            $0 != .WINK_LEFT &&
            $0 != .WINK_RIGHT
        }

    case .WINK:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD &&
            $0 != .YAW_LEFT &&
            $0 != .YAW_RIGHT &&
            $0 != .PITCH_UP &&
            $0 != .PITCH_DOWN
        }

    case .NON:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD
        }
    }
}
