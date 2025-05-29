
import Foundation

@objc public enum FaceEvents:Int {
   case ROLL_LEFT
   case ROLL_RIGHT
   case YAW_LEFT
   case YAW_RIGHT
   case PITCH_UP
   case PITCH_DOWN
   case GOOD
   case NO_DETECT
}


@objc public enum ActiveLiveEvents: Int, CaseIterable {
    case YAW_LEFT
    case YAW_RIGHT
    case PITCH_UP
    case PITCH_DOWN
    case GOOD
}

func getRandomEvents() -> Set<ActiveLiveEvents> {
    let allEvents = ActiveLiveEvents.allCases.filter { $0 != .GOOD }
    var randomEvents = Set<ActiveLiveEvents>()
    
    while randomEvents.count < 3 && randomEvents.count < allEvents.count {
        if let randomEvent = allEvents.randomElement() {
            randomEvents.insert(randomEvent)
        }
    }
    
    return randomEvents
}
