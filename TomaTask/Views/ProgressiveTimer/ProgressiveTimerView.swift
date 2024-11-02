//
//  ProgressiveTimer.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 23/10/24.
//

import SwiftUI
import AudioToolbox

var defaultTimeStart: Double = 5 * 60
var defaultMinSeconds: Double = 3 * 60
var defaultMaxSeconds: Double = 25 * 60

struct ProgressiveTimerView: View {
    var type: Int = 1
    
    @State var hideUI: Bool = false
    @State var alarmSound: Bool = true
    @State var dimDisplay: Bool = false
    
    @State private var showingSheet: Bool = false
    
    @State private var meshValue1 = Float.random(in: 0.5...0.7)
    @State private var meshValue2 = Float.random(in: 0.4...0.8)
    
    @State var meshColor1: Color = .black
    @State var meshColor2: Color = .orange
    @State var meshColor3: Color = .red
        
    @State var heigth: CGFloat = screenSize
    
    @State private var selectedTime: Double = defaultTimeStart
    @State private var timer: Timer?
    @State var time: TimeInterval = 0
    @State private var isRunning: Bool = false
    @State private var isBreakTime: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                if type == 0 {
                    SolidTimer(heigth: heigth)
                        .onTapGesture {
                            withAnimation {
                                hideUI.toggle()
                            }
                        }
                } else {
                    MeshGradientTimer(
                        time: time,
                        meshColor1: meshColor1,
                        meshColor2: meshColor2,
                        meshColor3: meshColor3
                    )
                    .onTapGesture {
                        withAnimation {
                            hideUI.toggle()
                        }
                    }
                }
                
                TimerActions(alarmSound: $alarmSound, dimDisplay: $dimDisplay)
                    .hideUIAnimation(hideUI: hideUI)
                
                VStack (spacing: 8) {
                    Text(!isBreakTime ? "Focus time" : "Break time")
                        .font(.headline)
                    
                    Text(formattedTime())
                        .font(.system(size: 48, weight: .bold))
                    
                    HStack {
                        Button {
                            resetTimer()
                        } label: {
                            Label("Stop", systemImage: "stop.fill")
                                .font(.title)
                                .labelStyle(.iconOnly)
                                .contentTransition(.symbolEffect(.replace))
                                .opacity(time == selectedTime ? 0.3 : 1)
                        }.disabled(time == selectedTime)
                        
                        Button {
                            isRunning.toggle()
                            
                            isRunning ? startTimer() : pauseTimer()
                        } label: {
                            Label(!isRunning ? "Start" : "Pause", systemImage: isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .contentTransition(.symbolEffect(.replace))
                                .labelStyle(.iconOnly)
                        }
                    }.foregroundStyle(.primary)
                }
                .hideUIAnimation(hideUI: hideUI)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingSheet, onDismiss: {
            time = selectedTime
            if !isBreakTime {
                heigth = screenSize
            }
        }) {
            FeedbackSheet(selectedTime: $selectedTime, breakTime: $isBreakTime)
        }
        .onAppear(){
            time = defaultTimeStart
        }
    }
    
    func formattedTime () -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func handleMeshAnimation() {
        meshValue1 = cos(.random(in: 0.0...1.0)) > 0 ? Float.random(in: 0.5...0.7) : Float.random(in: 0.4...0.8)
        meshValue2 = cos(.random(in: 0.0...1.0)) < 0 ? Float.random(in: 0.4...0.6) : Float.random(in: 0.5...0.7)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if type == 1 {
                handleMeshAnimation()
            }
            
            if(time > 0) {
                isRunning = true
                
                time -= 1
                
                if(isBreakTime && type == 0) {
                    heigth += screenSize / CGFloat(selectedTime / 1)
                } else {
                    heigth -= screenSize / CGFloat(selectedTime / 1)
                }
            } else {
                pauseTimer()
                
                if alarmSound {
                    playSound()
                }
                
                showingSheet = true
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        hideUI = false
    }
    
    func resetTimer() {
        pauseTimer()
        
        isBreakTime = false
        
        time = defaultTimeStart
        
        selectedTime = defaultTimeStart
        
        if type == 0 {
            heigth = screenSize
        }
    }
   
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
 }

struct FeedbackSheet: View {
 @Environment(\.dismiss) var dismiss
      
 @Binding var selectedTime: Double
 @Binding var breakTime: Bool
 
var body: some View {
    VStack {
        Text("How do you feel?")
            .font(.title)
            .fontWeight(.semibold)
        
        VStack {
            Button {
                takeABreak()
            } label: {
                Text("I need a break")
                    .padding()
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button {
                useTheSameTime()
            } label: {
                Text("I need less time")
                    .padding()
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button {
                increaseTime()
            } label: {
                Text("I'm in the flow")
                    .padding()
                    .bold()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }.frame(maxWidth: UIScreen.main.bounds.width * 0.6)
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .padding()
}
 
 func takeABreak() {
     selectedTime = 5 * 60
     
     setBreak()
 }
 
 func setNoBreak() {
     breakTime = false
     dismiss()
 }
 
 func setBreak() {
     breakTime = true
     dismiss()
 }
 
 func useTheSameTime() {
     selectedTime = selectedTime - defaultMinSeconds <= defaultMinSeconds ? defaultMinSeconds : selectedTime - defaultMinSeconds
     
     setNoBreak()
 }
 
 func increaseTime() {
     selectedTime = selectedTime + defaultMinSeconds <= defaultMaxSeconds ? selectedTime + defaultMinSeconds : defaultMaxSeconds
     
     setNoBreak()
 }
}

struct HideUIAnimationModifier: ViewModifier {
    var hideUI: Bool
    
    func body(content: Content) -> some View {
        content
            .blur(radius: hideUI ? 10 : 0)
            .opacity(hideUI ? 0 : 1)
            .scaleEffect(hideUI ? 2 : 1)
            .animation(.spring(), value: hideUI)
    }
}

extension View {
    func hideUIAnimation(hideUI: Bool) -> some View {
        self.modifier(HideUIAnimationModifier(hideUI: hideUI))
    }
}

#Preview {
    ProgressiveTimerView(meshColor1: .black, meshColor2: .red, meshColor3: .orange)
}
