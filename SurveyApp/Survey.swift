//
//  Survey.swift
//  SurveyApp
//
//  Created by North on 7/21/2559 BE.
//  Copyright © 2559 North. All rights reserved.
//

import UIKit
import ObjectMapper

class Survey: Mappable {
    
    var title: String?
    var description: String?
    var cover_image_url: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        description <- map["description"]
        cover_image_url <- map["cover_image_url"]
    }

}
