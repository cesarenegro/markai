import SwiftUI

struct HelpView: View {
    @State private var selection: HelpTopic = .welcome
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        } detail: {
            detailContent
                .navigationSplitViewColumnWidth(min: 480, ideal: 720)
        }
        .navigationSplitViewStyle(.balanced)
        .navigationTitle("mARK.AI Help")
        .frame(minWidth: 800, minHeight: 560)
    }

    // MARK: - Filtering

    private var filteredGroups: [(name: String, topics: [HelpTopic])] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return HelpTopic.groups
        }
        let q = searchText.lowercased()
        return HelpTopic.groups.compactMap { group in
            let matching = group.topics.filter { $0.title.lowercased().contains(q) }
            return matching.isEmpty ? nil : (group.name, matching)
        }
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            sidebarHeader

            Divider()

            sidebarSearchField
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

            Divider()

            sidebarList
        }
        .background(.bar)
    }

    private var sidebarHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 1) {
                Text("mARK.AI Help")
                    .font(.headline)
                Text("User Guide")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var sidebarSearchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 12, weight: .medium))
            TextField("Search topics", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.secondary.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var sidebarList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2, pinnedViews: []) {
                ForEach(Array(filteredGroups.enumerated()), id: \.element.name) { index, group in
                    if index > 0 {
                        Divider()
                            .padding(.vertical, 4)
                    }
                    sectionHeader(group.name)
                    ForEach(group.topics) { topic in
                        sidebarRow(topic)
                    }
                }

                if filteredGroups.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("No topics match")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func sectionHeader(_ name: String) -> some View {
        Text(name.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 2)
    }

    private func sidebarRow(_ topic: HelpTopic) -> some View {
        let isSelected = selection == topic
        return Button {
            selection = topic
        } label: {
            HStack(spacing: 8) {
                Image(systemName: topic.icon)
                    .frame(width: 16)
                    .font(.system(size: 12, weight: .medium))
                Text(topic.title)
                    .font(.system(size: 13))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
    }

    // MARK: - Detail

    private var detailContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    breadcrumb
                        .id("top")

                    HelpContent(topic: selection, selection: $selection)
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.textBackgroundColor))
            .onChange(of: selection) { _, _ in
                withAnimation(.easeOut(duration: 0.18)) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
    }

    private var breadcrumb: some View {
        HStack(spacing: 6) {
            Image(systemName: selection.icon)
                .foregroundStyle(.secondary)
            Text(selection.groupTitle)
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.tertiary)
            Text(selection.title)
                .foregroundStyle(.primary)
        }
        .font(.caption)
    }
}

#Preview {
    HelpView()
        .frame(width: 980, height: 640)
}
