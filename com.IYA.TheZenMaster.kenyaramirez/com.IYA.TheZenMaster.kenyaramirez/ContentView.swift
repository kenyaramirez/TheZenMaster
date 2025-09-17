//
//  ContentView.swift
//  ZenMaster
//
//  Created by Kenya Ramirez on 9/16/25.
//

import SwiftUI

// MARK: - Root Content
struct ContentView: View {
    @State private var currentScreen: Screen = .title
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .title:
                TitleScreenView(currentScreen: $currentScreen)
            case .login:
                LoginView(currentScreen: $currentScreen)
            case .welcome:
                WelcomeView(currentScreen: $currentScreen)
            case .zen:
                ZenRoomView(currentScreen: $currentScreen)
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }
}

// MARK: - Screen Enum
enum Screen {
    case title, login, welcome, zen
}

// MARK: - Title Screen (uses ZenTitleScreen)
struct TitleScreenView: View {
    @Binding var currentScreen: Screen
    
    var body: some View {
        ZStack {
            Image("ZenTitleScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                // Darken slightly so white text is readable
                .overlay(Color.black.opacity(0.35))
            
            VStack(spacing: 12) {
                Text("Being Peace")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                
                Text("Swipe left to begin your journey")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(radius: 2)
                
                Spacer()
            }
            .padding(.top, 80)
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width < -50 {
                    currentScreen = .login
                }
            }
        )
    }
}

// MARK: - Login Screen (keeps gradient)
struct LoginView: View {
    @Binding var currentScreen: Screen
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = ""
    @AppStorage("userPhone") private var userPhone = ""
    
    @State private var tempName = ""
    @State private var tempAge = ""
    @State private var tempPhone = ""
    
    let ageOptions = Array(18...100).map { "\($0)" }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .green]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text("Name").foregroundColor(.white)
                    TextField("Enter your name", text: $tempName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Age").foregroundColor(.white)
                    Picker("Age", selection: $tempAge) {
                        ForEach(ageOptions, id: \.self) { age in
                            Text(age).tag(age)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Phone Number").foregroundColor(.white)
                    TextField("Enter your phone number", text: $tempPhone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button("Continue") {
                    userName = tempName
                    userAge = tempAge
                    userPhone = tempPhone
                    currentScreen = .welcome
                }
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .foregroundColor(.black)
                .padding(.horizontal, 40)
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 50 {
                    currentScreen = .title
                } else if value.translation.width < -50 {
                    currentScreen = .welcome
                }
            }
        )
    }
}

// MARK: - Welcome Screen (reuses ZenTitleScreen until you add a dedicated image)
struct WelcomeView: View {
    @Binding var currentScreen: Screen
    @AppStorage("userName") private var userName = ""
    
    var body: some View {
        ZStack {
            Image("ZenTitleScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35)) // keep text readable
            
            VStack(spacing: 20) {
                Text("Welcome, \(userName)!")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                
                Text("Enjoy your journey")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Swipe left or right to move 🌿")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 24)
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 50 {
                    currentScreen = .login
                } else if value.translation.width < -50 {
                    currentScreen = .zen
                }
            }
        )
    }
}

// MARK: - Zen Room Screen (uses sand)
struct ZenRoomView: View {
    @Binding var currentScreen: Screen
    @State private var breatheIn = true
    @State private var scale: CGFloat = 1.0
    @State private var text = "Breathe in"
    @State private var opacity: Double = 1.0
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            Image("sand")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Breathing text
            Text(text)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
                .shadow(radius: 3)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear { startBreathing() }
                .onDisappear { timer?.invalidate() }
        }
        .gesture(
            DragGesture().onEnded { value in
                // Free movement back to Welcome in either direction
                if value.translation.width > 50 || value.translation.width < -50 {
                    currentScreen = .welcome
                }
            }
        )
    }
    
    private func startBreathing() {
        withAnimation(.easeInOut(duration: 4)) {
            scale = 1.2
            text = "Breathe in"
            opacity = 1.0
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            if breatheIn {
                text = "Breathe out"
                withAnimation(.easeInOut(duration: 4)) {
                    scale = 0.8
                    opacity = 0.95
                }
            } else {
                text = "Breathe in"
                withAnimation(.easeInOut(duration: 4)) {
                    scale = 1.2
                    opacity = 1.0
                }
            }
            breatheIn.toggle()
        }
    }
}

#Preview {
    ContentView()
}
