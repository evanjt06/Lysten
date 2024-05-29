import Foundation
import CoreData


extension PlayMusic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayMusic> {
        let request =  NSFetchRequest<PlayMusic>(entityName: "PlayMusic")
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }

    @NSManaged public var duration: String
    @NSManaged public var link: String
    @NSManaged public var title: String
    @NSManaged public var date: Date

}

extension PlayMusic : Identifiable {

}

