import WidgetKit
import SwiftUI

@main
struct ForwardNeckWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ForwardNeckWidget()
    }
}
