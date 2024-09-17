//
//  SoundManager.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        let sounds = ["achievement", "checkmark", "all_complete"]
        for sound in sounds {
            if let url = Bundle.main.url(forResource: sound, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound] = player
                    print("Successfully set up audio player for \(sound)")
                } catch {
                    print("Error setting up audio player for \(sound): \(error)")
                }
            } else {
                print("Could not find sound file: \(sound)")
            }
        }
        print("Audio players setup complete. Total players: \(audioPlayers.count)")
    }
    
    func playSound(_ sound: String) {
        print("Attempting to play sound: \(sound)")
        guard let player = audioPlayers[sound] else {
            print("No audio player found for sound: \(sound)")
            return
        }
        
        player.currentTime = 0
        player.play()
        
        if player.isPlaying {
            print("Sound \(sound) is playing")
        } else {
            print("Failed to play sound \(sound)")
        }
    }
}