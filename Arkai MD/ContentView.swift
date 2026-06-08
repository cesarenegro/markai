import SwiftUI

#Preview {
    EditorView(
        controller: EditorController(),
        onSave: {},
        onMakeSkill: {}
    )
    .environment(EditorState())
    .environment(VaultState())
    .frame(width: 700, height: 500)
}
