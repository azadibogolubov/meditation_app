//
//  TrackListView.swift
//  MeditationTimer
//
//  Created by Azadi Bogolubov on 7/24/26.
//

import SwiftUI

struct TrackListView: View {
    let onSelectTrack: (MeditationTrack) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(sampleTracks) { track in
                Button {
                    onSelectTrack(track)
                } label: {
                    HStack(spacing: 12) {
                        Image(track.imageName)
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 120, height: 68)
                            .clipped()
                            .cornerRadius(8)

                        Text(track.title)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
