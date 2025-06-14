//
//  SwiftUI+Font.swift
//  Squest
//
//  Created by Star Feng on 6/7/25.
//

import SwiftUI

extension Font {
    static func funnel(s: CGFloat) -> Font {
        return Font.custom("FunnelDisplay-Bold", size: s)
    }
    static func firaSans(s: CGFloat) -> Font {
        return Font.custom("FiraSans-Regular", size: s)
    }
    static func firaSansBold(s: CGFloat) -> Font {
        return Font.custom("FiraSans-Bold", size: s)
    }
    static func albertSans(s: CGFloat) -> Font {
        return Font.custom("AlbertSans-Regular", size: s)
    }
}

