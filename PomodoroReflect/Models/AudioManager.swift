//
//  AudioManager.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 10/15/24.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    var silentAudioPlayer: AVAudioPlayer?
    var timerEndAudioPlayer: AVAudioPlayer?

    func playSilentAudio() {
        let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3")!
        do {
            // Set up the audio session for background playback
            try AVAudioSession.sharedInstance().setCategory(.playback, options:[.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Play the silent audio file
            silentAudioPlayer = try AVAudioPlayer(contentsOf: silenceURL)
            silentAudioPlayer?.numberOfLoops = -1 // Loop indefinitely
            silentAudioPlayer?.play()
        } catch {
            print("Error playing silent audio: \(error.localizedDescription)")
        }
    }

    func stopSilentAudio() {
        silentAudioPlayer?.stop()
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
