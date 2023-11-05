import SwiftUI

struct HomePage: View {
    @State private var timerCounting = false
    @State private var startTime: Date?
    @State private var stopTime: Date?
    @State private var elapsedTime: Int = 0

    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    let STOP_TIME_KEY = "stopTime"
    let COUNTING_KEY = "countingKey"
    let fastingDurationInSeconds: Int = 1 * 3600


    var body: some View {
        NavigationView {
            VStack {
                Text("Orucun \(calculatePercentageCompleted())% tamamlandı.")
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 15)
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsedTime) / CGFloat(fastingDurationInSeconds))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(makeTimeString(hour: elapsedTime / 3600, min: (elapsedTime % 3600) / 60, sec: (elapsedTime % 3600) % 60))
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .frame(width: 200, height: 200)
                .padding(.bottom)
                .padding(.top)

                HStack {
                    Button(action: {
                        if timerCounting {
                            setStopTime(date: Date())
                            stopTimer()
                        } else {
                            if let start = startTime, let stop = stopTime {
                                let restartTime = calcRestartTime(start: start, stop: stop)
                                setStopTime(date: nil)
                                setStartTime(date: restartTime)
                            } else {
                                setStartTime(date: Date())
                            }
                            startTimer()
                        }
                    }) {
                        Text(timerCounting ? "Stop" : "Start")
                            .font(.headline)
                            .padding()
                            .background(timerCounting ? Color.blue : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    

                }
            }
            .navigationBarTitle("Intermittent Fasting")
        }
        .onAppear(perform: {
            startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
            stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
            timerCounting = userDefaults.bool(forKey: COUNTING_KEY)

            if timerCounting {
                startTimer()
            } else {
                stopTimer()
                if let start = startTime, let stop = stopTime {
                    let time = calcRestartTime(start: start, stop: stop)
                    let diff = Date().timeIntervalSince(time)
                    elapsedTime = Int(diff)
                }
            }
        })
    }

    func calcRestartTime(start: Date, stop: Date) -> Date {
        let diff = stop.timeIntervalSince(start)
        return Date().addingTimeInterval(diff)
    }

    func startTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let start = startTime {
                let diff = Date().timeIntervalSince(start)
                elapsedTime = Int(diff)
            }
        }
        RunLoop.current.add(timer, forMode: .common)
        setTimerCounting(true)
    }

    func stopTimer() {
        setStopTime(date: Date())
        setTimerCounting(false)
        elapsedTime = 0
        startTime = nil
    }

    

    func resetAction() {
        setStopTime(date: nil)
        setStartTime(date: nil)
        elapsedTime = 0
        stopTimer()
    }

    func setStartTime(date: Date?) {
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }

    func setStopTime(date: Date?) {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }

    func setTimerCounting(_ val: Bool) {
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_KEY)
    }

    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    func calculatePercentageCompleted() -> Int {
            if elapsedTime >= fastingDurationInSeconds {
                return 100
            } else {
                return Int((Double(elapsedTime) / Double(fastingDurationInSeconds)) * 100)
            }
        }
    }

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
