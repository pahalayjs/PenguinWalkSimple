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
    
    //logika baru penguibn utk nentuin dia lagingapain
    var penguinStatus: (imageName: String, message: String, color: Color) {
        if stepCount < 30 {
            return ("egg_pixel", "Masih telur, jangan cuma duduk!", .gray)
        } else if stepCount < 60 {
            return ("baby_pixel", "Netas! Mulai gerak, bakar kalori.", .yellow)
        } else if stepCount < 90 {
            return ("walk_pixel", "Kardio aktif. Terus jalan!", .orange)
        } else {
            return ("muscular_pixel", "BOOM! 1000 Langkah. Otot terbentuk!", .blue)
        }
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
                VStack(spacing: 20){
                    Image(penguinStatus.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        //.foregroundColor(penguinStatus.color)
                        .animation(.spring(), value: stepCount)
                    Text(penguinStatus.message)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                //dsiplay counter
                VStack {
                    Text("\(stepCount)")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                    Text("Steps today")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                //tombol reset dan simulasi, disabled
//                HStack(spacing:20 ) {
//                    //tombol reset
//                    Button(action: {
//                        stepCount = 0
//                        let impact = UIImpactFeedbackGenerator(style: .heavy)
//                            impact.impactOccurred()
//                    }) {
//                        Image(systemName: "trash")
//                            .font(.title2)
//                            .padding()
//                            .background(Color.red.opacity(0.2))
//                            .foregroundColor(.red)
//                            .cornerRadius(12)
//                    }
//                    //tombol siumulasi
//                    Button(action: {
//                        stepCount += 1
//                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                        impactMed.impactOccurred()
//                    }) {
//                        Text("Jalan Yuk! (+1)")
//                            .font(.headline)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                    .padding(.horizontal)
//                }
                
                Text("Bring ur iphone to hatch the penguin")
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
    }
    //place where magic happens
    func startNgitungLangkah() {
        if CMPedometer.isStepCountingAvailable() {
            // miinta data mulai dari jam 00:00 hari ini
            let awalHariIni = Calendar.current.startOfDay(for: Date())
            
            //nyalakan sensorn
            pedometer.startUpdates(from: awalHariIni) { dataLangkah, error in
                // kalo ada data yg masuk dari iphone
                if let data = dataLangkah {
                    DispatchQueue.main.async {
                        self.stepCount = Int(truncating: data.numberOfSteps)
                    }
                }
                
            }
        } else {
            print("sensor langkah ga tersedia di perangkat ini")
        }
    }
    
}

#Preview {
    ContentView()
}
