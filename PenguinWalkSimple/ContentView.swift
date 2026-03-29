//
//  ContentView.swift
//  PenguinWalkSimple
//
//  Created by Pahala Sihombing on 16/02/26.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    //bikin mesin pedometer penghitung lagkah
    private let pedometer = CMPedometer()
    
    // dgn pakai appstorage, data disipman di memori hp, kalau @state doang bakalan ilang kalau dikill, tapi karna pakai coremotion, data udah ada di sistem, jadi pakai @state fungsinya vari sementara buat nampilin di layar
    @State private var stepCount: Int = 0
    
//    let targetHarian: Int = 1000

    // pakai appstorage utk bikin wadah target harian, pertama instal, targetnya 1k
    @AppStorage("targetHarian") private var targetHarian: Int = 1000
    
    
    //logika baru penguibn utk nentuin dia lagingapain
    // update = nambain target
    var penguinStatus: (imageName: String, message: String, color: Color) {
        
        let p25 = targetHarian/4
        let p50 = targetHarian/2
        
        if stepCount < p25 {
            return ("egg_pixel", "Masih telur, jangan cuma duduk!", .gray)
        } else if stepCount < p50 {
            return ("baby_pixel", "Netas! Mulai gerak, bakar kalori.", .yellow)
        } else if stepCount < targetHarian {
            return ("walk_pixel", "Kardio aktif. Terus jalan!", .orange)
        } else {
            return ("muscular_pixel", "BOOM! 1000 Langkah. Otot terbentuk!", .blue)
        }
    }
    
    //ubah lanbgkah jadi persentase utk isi circle
    var stepProgress: Double {
        let progress = Double(stepCount) / Double(targetHarian)
        return min(progress, 1.0)
    }
    
    var body: some View {
        ZStack {
            //ini bg color
            
            //Color.blue.opacity(0.1)
            //    .ignoresSafeArea()
            
            //bg dinamis sesuai warna status
            penguinStatus.color.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40){
                // ini header
                Text("Penguin Walk")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(penguinStatus.color)
                // tampilan ikon dinamis dan message
                
                //update visual progress circle
                VStack(spacing: 30){
                    ZStack {
                        // bg circle jalur
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.2)
                            .foregroundColor(penguinStatus.color)
                        //circle pengisi sesuai langkah
                        Circle()
                        // trim buat motong sesuai presentase
                            .trim(from: 0.0, to: CGFloat(stepProgress))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .rotationEffect(Angle(degrees: -90))
                            .foregroundColor(penguinStatus.color)
                            .animation(.linear(duration: 0.5), value: stepProgress)
                        Image(penguinStatus.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130, height: 130)
                        //.foregroundColor(penguinStatus.color)
                            .animation(.spring(), value: stepCount)
                    }
                    .frame(width: 240, height: 240) //ukuran total cincin
                    
                    Text(penguinStatus.message)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(penguinStatus.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                //dsiplay counter
                VStack(spacing: 10) {
                    Text("\(stepCount)")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                    
                    //stepper buat nambah/ngurangin target kelipatan 1k
                    Stepper(value: $targetHarian, in: 1000...50000, step: 1000) {
                        Text("Target Harian: \(targetHarian)")
                            .font(.headline)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 40)
//                    Text("Target Harian: \(targetHarian)")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
                }
                
                Text("Bawa iPhone-mu berjalan untuk menetaskan Penguin!")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

            }
            .padding()
        }
        .onAppear{
            startNgitungLangkah()
        }
        .onChange(of: penguinStatus.imageName) { oldImage, newImage in
            //haptic ketika gbr berubah (naik level)
            if newImage != newImage {
                mainkanGetaran(tipe: .heavy)
            }
        }
    }
    //place where magic happens
    func startNgitungLangkah() {
        if CMPedometer.isStepCountingAvailable() {
            // miinta data mulai dari jam 00:00 hari ini
            let awalHariIni = Calendar.current.startOfDay(for: Date())
            
            //query instanss tarik data dari jam 00 ke detik ini
            pedometer.queryPedometerData(from: awalHariIni, to: Date()) { dataMasaLalu, error in
                if let data = dataMasaLalu {
                    DispatchQueue.main.async {
                        self.stepCount = Int(truncating: data.numberOfSteps)
                    }
                }
                
            }
            
            //live update step count
            pedometer.startUpdates(from: Date()) { dataBaru, error in
                // kalo ada data yg masuk dari iphone
                if let data = dataBaru {
                    DispatchQueue.main.async {
                        //tambhain langkah baru ke langkah ygudah ada
                        self.stepCount = Int(truncating: data.numberOfSteps)
                    }
                    print("sensor langkah tersedia di perangkat ini")

                }
                
            }
        } else {
            print("sensor langkah ga tersedia di perangkat ini")
        }
    }
    
}

//haptic feedback

func mainkanGetaran(tipe: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: tipe)
    generator.impactOccurred()
}

#Preview {
    ContentView()
}
