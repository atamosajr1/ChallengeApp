//
//  ApiResponse.swift
//  ChallengeApp
//
//  Created by Jayr Atamosa on 22/08/2019.
//  Copyright © 2019 Jayr Atamosa. All rights reserved.
//

import UIKit

struct AuthorResponse: Codable
{
  var result:[Author]
}

struct PostResponse: Codable
{
  var result:[Post]
}
