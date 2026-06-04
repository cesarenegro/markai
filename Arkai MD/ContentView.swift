import SwiftUI

#Preview {
    EditorView(
        controller: EditorController(),
        onSave: {},
        onMakeSkill: {}
    )
    .environment(EditorState())
    .frame(width: 700, height: 500)
}
