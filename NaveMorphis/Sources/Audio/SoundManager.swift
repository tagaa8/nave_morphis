import AVFoundation
import SpriteKit

enum SoundEffect: String, CaseIterable {
    case laserFire = "laser_fire"
    case laserHit = "laser_hit"
    case enemyFire = "enemy_fire"
    case enemyExplosion = "enemy_explosion"
    case playerDamage = "player_damage"
    case playerExplosion = "player_explosion"
    case powerUpCollect = "power_up_collect"
    case powerUpActivate = "power_up_activate"
    case mothershipFire = "mothership_fire"
    case mothershipMissile = "mothership_missile"
    case mothershipBeamCharge = "mothership_beam_charge"
    case mothershipBeamFire = "mothership_beam_fire"
    case mothershipEnraged = "mothership_enraged"
    case mothershipDestroyed = "mothership_destroyed"
    case moduleDestroyed = "module_destroyed"
    case menuSelect = "menu_select"
    case menuConfirm = "menu_confirm"
    case waveStart = "wave_start"
    case gameOver = "game_over"
    case victory = "victory"
}

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var soundActions: [String: SKAction] = [:]
    
    var masterVolume: Float = GameConfig.Audio.masterVolume {
        didSet {
            updateAllVolumes()
        }
    }
    
    var sfxVolume: Float = GameConfig.Audio.sfxVolume {
        didSet {
            updateAllVolumes()
        }
    }
    
    private init() {
        setupAudioSession()
        preloadSounds()
        createSoundActions()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        for sound in SoundEffect.allCases {
            if let url = createSoundFile(for: sound) {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = masterVolume * sfxVolume
                    audioPlayers[sound.rawValue] = player
                } catch {
                    print("Failed to load sound \(sound.rawValue): \(error)")
                }
            }
        }
    }
    
    private func createSoundActions() {
        for sound in SoundEffect.allCases {
            if let _ = audioPlayers[sound.rawValue] {
                soundActions[sound.rawValue] = SKAction.playSoundFileNamed("\(sound.rawValue).wav", waitForCompletion: false)
            }
        }
    }
    
    private func createSoundFile(for sound: SoundEffect) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let soundURL = documentsPath.appendingPathComponent("\(sound.rawValue).wav")
        
        if !FileManager.default.fileExists(atPath: soundURL.path) {
            generatePlaceholderSound(for: sound, at: soundURL)
        }
        
        return soundURL
    }
    
    private func generatePlaceholderSound(for sound: SoundEffect, at url: URL) {
        let sampleRate: Double = 44100
        let duration: Double = getDuration(for: sound)
        let frequency = getFrequency(for: sound)
        
        let frameCount = Int(sampleRate * duration)
        var samples = [Float]()
        
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            var amplitude: Float = 0.3
            
            switch sound {
            case .laserFire:
                amplitude = Float(0.4 * sin(2 * .pi * frequency * time) * exp(-time * 2))
            case .laserHit:
                amplitude = Float(0.5 * sin(2 * .pi * frequency * time) * exp(-time * 5))
            case .enemyFire:
                amplitude = Float(0.3 * sin(2 * .pi * (frequency * 0.8) * time) * exp(-time * 1.5))
            case .enemyExplosion, .playerExplosion, .mothershipDestroyed:
                let noise = Float.random(in: -1...1)
                amplitude = Float(0.6 * noise * exp(-time * 1.2))
            case .playerDamage:
                amplitude = Float(0.4 * sin(2 * .pi * (frequency * 0.5) * time) * exp(-time * 3))
            case .powerUpCollect:
                amplitude = Float(0.3 * sin(2 * .pi * (frequency + Double(i) * 10) * time) * exp(-time * 0.8))
            case .powerUpActivate:
                amplitude = Float(0.4 * sin(2 * .pi * (frequency * 1.5) * time) * exp(-time * 0.5))
            case .mothershipFire:
                amplitude = Float(0.5 * sin(2 * .pi * (frequency * 0.6) * time) * exp(-time * 1))
            case .mothershipMissile:
                amplitude = Float(0.4 * sin(2 * .pi * frequency * time) * sin(2 * .pi * 5 * time) * exp(-time * 0.8))
            case .mothershipBeamCharge:
                amplitude = Float(0.3 * sin(2 * .pi * (frequency + time * 200) * time))
            case .mothershipBeamFire:
                amplitude = Float(0.7 * sin(2 * .pi * (frequency * 2) * time) * exp(-time * 0.5))
            case .mothershipEnraged:
                let noise = Float.random(in: -0.5...0.5)
                amplitude = Float(0.5 * (sin(2 * .pi * frequency * time) + noise) * exp(-time * 0.3))
            case .moduleDestroyed:
                let noise = Float.random(in: -1...1)
                amplitude = Float(0.4 * noise * exp(-time * 2))
            case .menuSelect:
                amplitude = Float(0.2 * sin(2 * .pi * 800 * time) * exp(-time * 8))
            case .menuConfirm:
                amplitude = Float(0.3 * sin(2 * .pi * 1000 * time) * exp(-time * 2))
            case .waveStart:
                amplitude = Float(0.4 * sin(2 * .pi * (600 + time * 400) * time) * exp(-time * 0.8))
            case .gameOver:
                amplitude = Float(0.4 * sin(2 * .pi * (400 - time * 100) * time) * exp(-time * 0.5))
            case .victory:
                amplitude = Float(0.3 * sin(2 * .pi * (500 + sin(time * 10) * 100) * time) * exp(-time * 0.3))
            }
            
            amplitude *= Float(masterVolume * sfxVolume)
            samples.append(amplitude)
        }
        
        saveWAVFile(samples: samples, sampleRate: Int(sampleRate), to: url)
    }
    
    private func getDuration(for sound: SoundEffect) -> Double {
        switch sound {
        case .laserFire, .enemyFire: return 0.2
        case .laserHit: return 0.1
        case .playerDamage: return 0.3
        case .powerUpCollect: return 0.4
        case .powerUpActivate: return 0.6
        case .menuSelect: return 0.1
        case .menuConfirm: return 0.2
        case .mothershipFire: return 0.3
        case .mothershipMissile: return 0.5
        case .mothershipBeamCharge: return 2.0
        case .mothershipBeamFire: return 0.8
        case .mothershipEnraged: return 1.5
        case .waveStart: return 1.0
        case .gameOver: return 2.0
        case .victory: return 3.0
        default: return 0.8
        }
    }
    
    private func getFrequency(for sound: SoundEffect) -> Double {
        switch sound {
        case .laserFire: return 800
        case .laserHit: return 600
        case .enemyFire: return 400
        case .playerDamage: return 200
        case .powerUpCollect: return 1000
        case .powerUpActivate: return 1200
        case .menuSelect: return 800
        case .menuConfirm: return 1000
        case .mothershipFire: return 300
        case .mothershipMissile: return 500
        case .mothershipBeamCharge: return 150
        case .mothershipBeamFire: return 600
        case .mothershipEnraged: return 180
        case .waveStart: return 600
        case .gameOver: return 400
        case .victory: return 500
        default: return 440
        }
    }
    
    private func saveWAVFile(samples: [Float], sampleRate: Int, to url: URL) {
        let numChannels = 1
        let bitsPerSample = 16
        let bytesPerSample = bitsPerSample / 8
        let blockAlign = numChannels * bytesPerSample
        let byteRate = sampleRate * blockAlign
        let dataSize = samples.count * bytesPerSample
        let fileSize = 44 + dataSize
        
        var data = Data()
        
        data.append("RIFF".data(using: .ascii)!)
        data.append(withUnsafeBytes(of: UInt32(fileSize - 8).littleEndian) { Data($0) })
        data.append("WAVE".data(using: .ascii)!)
        
        data.append("fmt ".data(using: .ascii)!)
        data.append(withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt16(numChannels).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt16(blockAlign).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: UInt16(bitsPerSample).littleEndian) { Data($0) })
        
        data.append("data".data(using: .ascii)!)
        data.append(withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Data($0) })
        
        for sample in samples {
            let intSample = Int16(sample * Float(Int16.max))
            data.append(withUnsafeBytes(of: intSample.littleEndian) { Data($0) })
        }
        
        do {
            try data.write(to: url)
        } catch {
            print("Failed to save WAV file: \(error)")
        }
    }
    
    func playSound(_ sound: SoundEffect) {
        if let player = audioPlayers[sound.rawValue] {
            player.stop()
            player.currentTime = 0
            player.play()
        }
    }
    
    func playSoundAction(_ sound: SoundEffect) -> SKAction? {
        return soundActions[sound.rawValue]
    }
    
    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
    }
    
    private func updateAllVolumes() {
        for player in audioPlayers.values {
            player.volume = masterVolume * sfxVolume
        }
    }
    
    func setVolume(_ volume: Float, for sound: SoundEffect) {
        audioPlayers[sound.rawValue]?.volume = volume * masterVolume * sfxVolume
    }
    
    func isPlaying(_ sound: SoundEffect) -> Bool {
        return audioPlayers[sound.rawValue]?.isPlaying ?? false
    }
}