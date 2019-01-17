import Foundation

extension Wind {
    enum Direction: String {
        case N
        case NNE
        case NE
        case ENE
        case E
        case ESE
        case SE
        case SSE
        case S
        case SSW
        case SW
        case WSW
        case W
        case WNW
        case NW
        case NNW
        
        static func fromDegree(_ deg: Int) -> Direction {
            switch deg {
            case 11...33:
                return .NNE
            case 34...56:
                return .NE
            case 57...78:
                return .ENE
            case 79...101:
                return .E
            case 102...123:
                return .ESE
            case 124...146:
                return .SE
            case 147...168:
                return .SSE
            case 169...191:
                return .S
            case 192...213:
                return .SSW
            case 214...236:
                return .SW
            case 237...258:
                return .WSW
            case 259...281:
                return.W
            case 282...303:
                return .WNW
            case 304...326:
                return .NW
            case 327...348:
                return .NNW
            default:
                return .N
            }
        }
    }
    
    var cardinalDirection: Direction? {
        guard let deg = deg else {
            return nil
        }
        return Direction.fromDegree(Int(deg))
    }
}
