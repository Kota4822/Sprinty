import Foundation
import Commander

Group {
    $0.command("run") {
        JiraSprintCLI.run()
    }
    }.run()
