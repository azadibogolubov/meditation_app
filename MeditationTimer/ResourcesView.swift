//
//  ResourcesView.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/25/26.
//

import SwiftUI

struct ResourcesView: View {
    @State private var links: [ResourceLink] = []

    var body: some View {
        NavigationStack {
            List(links) { link in
                Link(destination: link.linkURL) {
                    HStack {
                        Image(systemName: link.systemImage)
                            .foregroundStyle(.tint)
                            .frame(width: 28)
                        VStack(alignment: .leading) {
                            Text(link.title).foregroundStyle(.primary)
                            Text(link.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .navigationTitle("Resources")
            .onAppear { links = ResourceLoader.loadResources() }
        }
    }
}
