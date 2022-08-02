//
//  TiktokSongs+CoreDataProperties.swift
//  Lysten
//
//  Created by Evan Tu on 8/1/22.
//
//

import Foundation
import CoreData


extension TiktokSongs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TiktokSongs> {
        let request =  NSFetchRequest<TiktokSongs>(entityName: "TiktokSongs")
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }

    @NSManaged public var date: Date
    @NSManaged public var duration: String
    @NSManaged public var link: String
    @NSManaged public var title: String

}

extension TiktokSongs : Identifiable {

}
