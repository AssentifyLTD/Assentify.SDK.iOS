
import Foundation

@objc public enum FaceEvents:Int {
   case ROLL_LEFT
   case ROLL_RIGHT
   case YAW_LEFT
   case YAW_RIGHT
   case PITCH_UP
   case PITCH_DOWN
   case GOOD
   case WINK_LEFT
   case WINK_RIGHT
   case BLINK
   case NO_DETECT
    
}


@objc public enum ActiveLiveEvents: Int, CaseIterable {
    case YAW_LEFT
    case YAW_RIGHT
    case PITCH_UP
    case PITCH_DOWN
    case WINK_LEFT
    case WINK_RIGHT
    case BLINK
    case GOOD
    
}


@objc public enum ActiveLiveType: Int, CaseIterable {
    case ACTIONS
    case WINK
    case BLINK
    case NONE
}



func getRandomEvents(activeLiveType: ActiveLiveType, activeLivenessCheckCount: Int) -> [ActiveLiveEvents] {
    let allEvents = getFilteredEventsByType(type: activeLiveType)
    
    if allEvents.isEmpty {
        return []
    }
    
    var randomEvents: [ActiveLiveEvents] = []
    for _ in 0..<activeLivenessCheckCount {
        if let randomEvent = allEvents.randomElement() {
            randomEvents.append(randomEvent)
        }
    }
    
    return randomEvents
}


func getFilteredEventsByType(type: ActiveLiveType) -> [ActiveLiveEvents] {
    switch type {
    case .ACTIONS:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD &&
            $0 != .BLINK &&
            $0 != .WINK_LEFT &&
            $0 != .WINK_RIGHT
        }

    case .WINK:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD &&
            $0 != .BLINK &&
            $0 != .YAW_LEFT &&
            $0 != .YAW_RIGHT &&
            $0 != .PITCH_UP &&
            $0 != .PITCH_DOWN
        }
    case .BLINK:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD &&
            $0 != .YAW_LEFT &&
            $0 != .YAW_RIGHT &&
            $0 != .PITCH_UP &&
            $0 != .PITCH_DOWN &&
            $0 != .WINK_LEFT &&
            $0 != .WINK_RIGHT
        }

    case .NONE:
        return ActiveLiveEvents.allCases.filter {
            $0 != .GOOD
        }
    }
}
