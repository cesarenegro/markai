import SwiftUI

enum GraphMode: String, CaseIterable, Identifiable {
    case local = "Local"
    case global = "Global"

    var id: String { rawValue }
}

struct GraphView: View {
    @Environment(VaultState.self) private var vault
    @Environment(EditorState.self) private var editorState
    @Environment(\.dismiss) private var dismiss

    @State private var mode: GraphMode = .local
    @State private var pan: CGSize = .zero
    @State private var panStart: CGSize = .zero
    @State private var zoom: CGFloat = 1.0
    @State private var zoomStart: CGFloat = 1.0
    @State private var didSetInitialZoom: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .frame(minWidth: 720, minHeight: 520)
        .background(.background)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Graph")
                .font(.headline)

            Picker("Mode", selection: $mode) {
                ForEach(GraphMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    zoom = clampZoom(zoom / 1.15)
                    zoomStart = zoom
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                }
                .help("Zoom Out")

                Text("\(Int(zoom * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                    .frame(width: 56, alignment: .center)

                Button {
                    zoom = clampZoom(zoom * 1.15)
                    zoomStart = zoom
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                }
                .help("Zoom In")

                Button {
                    zoom = 1.0
                    zoomStart = 1.0
                    pan = .zero
                    panStart = .zero
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
            }

            Button("Done") { dismiss() }
                .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var content: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let model = GraphModel.build(from: vault, mode: mode)

            ZStack {
                Canvas { context, _ in
                    drawEdges(in: context, size: size, model: model)
                }

                ForEach(model.nodes) { node in
                    GraphNodeView(
                        title: node.title,
                        isSelected: node.url == vault.selectedNoteURL,
                        scale: nodeScale
                    )
                    .position(position(for: node.url, size: size, model: model))
                    .onTapGesture {
                        vault.selectedNoteURL = node.url
                        if editorState.isDirty, editorState.fileURL != nil {
                            editorState.save()
                        }
                        dismiss()
                    }
                }
            }
            .gesture(panGesture)
            .simultaneousGesture(zoomGesture)
            .onAppear { setInitialZoomIfNeeded(nodeCount: model.nodes.count) }
            .onChange(of: mode) { _, _ in
                didSetInitialZoom = false
                setInitialZoomIfNeeded(nodeCount: GraphModel.build(from: vault, mode: mode).nodes.count)
            }
            .clipped()
            .background(.background)
        }
    }

    private var nodeScale: CGFloat {
        min(max(zoom, 0.25), 1.35)
    }

    private func clampZoom(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.2), 3.0)
    }

    private func setInitialZoomIfNeeded(nodeCount: Int) {
        guard !didSetInitialZoom else { return }
        didSetInitialZoom = true

        let target: CGFloat
        switch mode {
        case .local:
            target = 1.0
        case .global:
            if nodeCount <= 12 {
                target = 0.95
            } else if nodeCount <= 30 {
                target = 0.65
            } else if nodeCount <= 60 {
                target = 0.45
            } else {
                target = 0.30
            }
        }

        zoom = clampZoom(target)
        zoomStart = zoom
        pan = .zero
        panStart = .zero
    }

    private func drawEdges(in context: GraphicsContext, size: CGSize, model: GraphModel) {
        let edgeColor = Color.secondary.opacity(0.35)
        var path = Path()

        for edge in model.edges {
            let from = position(for: edge.from, size: size, model: model)
            let to = position(for: edge.to, size: size, model: model)
            path.move(to: from)
            path.addLine(to: to)
        }

        context.stroke(path, with: .color(edgeColor), lineWidth: 1)
    }

    private func position(for url: URL, size: CGSize, model: GraphModel) -> CGPoint {
        let unit = model.unitPositions[url] ?? .zero
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let radius = min(size.width, size.height) * 0.38 * zoom

        return CGPoint(
            x: center.x + pan.width + unit.x * radius,
            y: center.y + pan.height + unit.y * radius
        )
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                pan = CGSize(
                    width: panStart.width + value.translation.width,
                    height: panStart.height + value.translation.height
                )
            }
            .onEnded { _ in
                panStart = pan
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zoom = clampZoom(zoomStart * value)
            }
            .onEnded { _ in
                zoomStart = zoom
            }
    }
}

private struct GraphNodeView: View {
    let title: String
    let isSelected: Bool
    let scale: CGFloat

    var body: some View {
        Text(title)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.22) : Color.secondary.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.65) : Color.secondary.opacity(0.18))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(scale)
    }
}

private struct GraphNode: Identifiable {
    var id: URL { url }
    let url: URL
    let title: String
}

private struct GraphEdge: Hashable {
    let from: URL
    let to: URL
}

private struct GraphModel {
    let nodes: [GraphNode]
    let edges: [GraphEdge]
    let unitPositions: [URL: CGPoint]

    static func build(from vault: VaultState, mode: GraphMode) -> GraphModel {
        switch mode {
        case .local:
            return buildLocal(from: vault)
        case .global:
            return buildGlobal(from: vault)
        }
    }

    private static func buildLocal(from vault: VaultState) -> GraphModel {
        guard let selected = vault.selectedNoteURL else {
            return GraphModel(nodes: [], edges: [], unitPositions: [:])
        }

        let noteByURL = Dictionary(uniqueKeysWithValues: vault.notes.map { ($0.url, $0) })

        let outgoingKeys = noteByURL[selected]?.outgoingWikiLinkKeys ?? []
        let outgoingTargets: [URL] = outgoingKeys.compactMap { vault.resolveWikiLinkTargetPath(for: $0) }

        let backlinkSources: [URL] = vault.backlinks(to: selected).map { $0.url }

        var urls: [URL] = [selected]
        urls.append(contentsOf: outgoingTargets)
        urls.append(contentsOf: backlinkSources)
        urls = Array(Set(urls))

        let nodes = urls
            .map { url in
                let title = noteByURL[url]?.title ?? url.deletingPathExtension().lastPathComponent
                return GraphNode(url: url, title: title)
            }
            .sorted { (lhs: GraphNode, rhs: GraphNode) in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }

        var edges: [GraphEdge] = []
        for target in outgoingTargets {
            edges.append(GraphEdge(from: selected, to: target))
        }
        for source in backlinkSources {
            edges.append(GraphEdge(from: source, to: selected))
        }

        var unitPositions: [URL: CGPoint] = [selected: .zero]

        let outgoingSorted = outgoingTargets
            .filter { $0 != selected }
            .sorted { ($0.lastPathComponent).localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        let backlinkSorted = backlinkSources
            .filter { $0 != selected }
            .sorted { ($0.lastPathComponent).localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }

        placeOnRing(urls: outgoingSorted, radius: 0.80, startAngle: .pi * 0.1, into: &unitPositions)
        placeOnRing(urls: backlinkSorted, radius: 1.05, startAngle: -.pi * 0.2, into: &unitPositions)

        if unitPositions[selected] == nil {
            unitPositions[selected] = .zero
        }

        return GraphModel(nodes: nodes, edges: edges, unitPositions: unitPositions)
    }

    private static func buildGlobal(from vault: VaultState) -> GraphModel {
        let notes = vault.notes
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        let nodes = notes.map { GraphNode(url: $0.url, title: $0.title) }
        var edges = Set<GraphEdge>()
        for note in notes {
            for key in note.outgoingWikiLinkKeys {
                guard let target = vault.resolveWikiLinkTargetPath(for: key) else { continue }
                edges.insert(GraphEdge(from: note.url, to: target))
            }
        }

        var unitPositions: [URL: CGPoint] = [:]
        let count = max(nodes.count, 1)
        for (index, node) in nodes.enumerated() {
            let angle = (CGFloat(index) / CGFloat(count)) * 2.0 * .pi
            unitPositions[node.url] = CGPoint(x: cos(angle), y: sin(angle))
        }

        return GraphModel(nodes: nodes, edges: Array(edges), unitPositions: unitPositions)
    }

    private static func placeOnRing(urls: [URL], radius: CGFloat, startAngle: CGFloat, into dict: inout [URL: CGPoint]) {
        guard !urls.isEmpty else { return }
        let count = urls.count
        for (i, url) in urls.enumerated() {
            let t = CGFloat(i) / CGFloat(count)
            let angle = startAngle + t * 2.0 * .pi
            dict[url] = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
        }
    }
}
