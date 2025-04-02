//
//  AudioManager.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/15/24.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    var bgAudioPlayer: AVAudioPlayer?
    var timerEndAudioPlayer: AVAudioPlayer?
    
    static var backgroundNoiseOptions = [
        "None",
        "Clock Tick",
        //        "White Noise",
    ]

    func playBgAudio(selectedAudio: String, isFocusTimer: Bool) {
        stopBgAudio()
        
        if (!isFocusTimer) {
            // Don't play any audio when not in focus timer
            return
        }
        
        switch (selectedAudio) {
        case AudioManager.backgroundNoiseOptions[0]:
                playSilentAudio()
                break
        case AudioManager.backgroundNoiseOptions[1]:
                playTickAudio()
                break
        default:
            print("Error in selected audio.")
        }
    }
    
    func playBgAudio(url: URL) {
        do {
            print("playing bg audio")
            // Set up the audio session for background playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options:[.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Play the audio file, with infinite loop
            bgAudioPlayer = try AVAudioPlayer(contentsOf: url)
            bgAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            bgAudioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func playSilentAudio() {
        let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")!
        playBgAudio(url: silenceURL)
    }
    
    // CURRENTLY: NOT IN SERVICE
    // White noise creates a noticeable sound when cut/ended
    func playWhiteNoiseAudio() {
        let whiteNoiseURL = Bundle.main.url(forResource: "underwater-white-noise", withExtension: "mp3")!
        playBgAudio(url: whiteNoiseURL)
    }
    
    func playTickAudio() {
        print("playing tick audio")
        let tickNoiseURL = Bundle.main.url(forResource: "two-tick", withExtension: "mp3")!
        playBgAudio(url: tickNoiseURL)
    }

    func stopBgAudio() {
        bgAudioPlayer?.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func playTimerEnd() {
        print("play timer end sound")
        guard let url = Bundle.main.url(forResource: "timer-end", withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        do {
            timerEndAudioPlayer = try AVAudioPlayer(contentsOf: url)
            timerEndAudioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
