//
//  CircleTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 26/09/24.
//

import SwiftUI

extension Animation {
    static func ripple() -> Animation {
        Animation.spring(response: 1, dampingFraction: 1)
            .speed(1.5)
    }
}

struct CircleTimer: View {
    @State private var timeRemaining: TimeInterval = 10
    @State private var timer: Timer?
    @State private var isRunning: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack (spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .fill(Color.black)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(1 - (timeRemaining / 10)))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .fill(Color.orange)
                        .rotationEffect(.degrees(-90))
                        .animation(.ripple(), value: timeRemaining)
                    
                    VStack {
                        Text(formattedTime())
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                    
                        Button {
                            withAnimation() {
                                isRunning.toggle()
                            }
                            
                            if isRunning {
                                startTimer()
                            } else {
                                stopTimer()
                            }
                        } label: {
                            Image(systemName: isRunning ? "pause.circle" : "play.circle")
                                .font(.title)
                        }
                    }
                }
                .padding()
                
                List {
                    HStack {
                        Text("🚀")
                            .font(.largeTitle)
                        
                        VStack (alignment: .leading) {
                            Text("Task 1")
                                .font(.headline)
                            Text("Description")
                                .font(.subheadline)
                        }

                    }
                }
            }
            .navigationTitle("TomaTask 1")
        }
    }
    
    func formattedTime () -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if(timeRemaining > 0) {
                isRunning = true
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        
        if(timeRemaining == 0){
            timeRemaining = 10
        }
    }
}

#Preview {
    CircleTimer()
}
