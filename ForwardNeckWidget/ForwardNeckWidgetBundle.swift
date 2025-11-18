import WidgetKit
import SwiftUI

@main
struct NeckRotWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        NeckRotWidget()
    }
}
