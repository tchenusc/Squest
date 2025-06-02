//
//  QuestCompletedPopUp.swift
//  Squest
//
//  Created by Star Feng on 6/1/25.
//

import SwiftUI

struct QuestCompletedPopUp: View {
    let questName: String
    let xp: Int
    let gold: Int
    let continueAction: () -> Void

    var body: some View {
        ZStack { // Main overlay ZStack
            // Background overlay
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            ZStack(alignment: .top) { // ZStack to layer star on top of content box
                VStack(spacing: 10) { // Inner VStack for pop-up content, reduced spacing
                    Text("Quest Completed!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 75) // Keep top padding to push content down
                        .lineLimit(1) // Ensure text is on a single line

                    Text(questName)
                        .font(.title2)
                        .foregroundColor(.white)

                    HStack(spacing: 20) { // Keep spacing between XP and Gold
                        HStack {
                            Image(systemName: "star.fill") // Use system image as a placeholder
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25) // Slightly larger purple star
                                .foregroundColor(.purple)
                            Text("\(xp) XP")
                                .foregroundColor(.white)
                        }

                        HStack {
                            Image("Goldcoin_questCompleted") // Use custom gold coin asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20) // Set frame for custom asset
                            Text("\(gold) Gold")
                                .foregroundColor(.white)
                        }
                    }
                    .font(.title3)
                    .padding(.top, 5) // Add a little space above XP/Gold

                    Button(action: continueAction) {
                        Text("Continue")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.8)) // Changed back to solid blue background
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20) // Add space between content and button
                }
                .padding(.horizontal, 15) // Further reduced horizontal padding
                .padding(.bottom, 25) // Keep bottom padding
                .background(Color.blue.opacity(0.4)) // Changed background color
                .cornerRadius(20)
                .shadow(radius: 10)

                // Star icon positioned to overlap
                Image("Star_questCompleted") // Use custom asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80) // Adjusted size again
                    .offset(y: -30) // Adjusted offset for overlap
            }
            .padding(.horizontal, 20) // Keep outer horizontal padding
        }
    }
}

struct QuestCompletedPopUp_Previews: PreviewProvider {
    static var previews:
 some View {
        QuestCompletedPopUp(questName: "Sample Quest Name", xp: 500, gold: 100, continueAction: {})
    }
} 
