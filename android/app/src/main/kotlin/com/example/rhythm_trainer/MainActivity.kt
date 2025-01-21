package com.example.rhythm_trainer
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.oboe.*
import android.os.Handler
import android.os.Looper

class MainActivity: FlutterActivity() {
    private val CHANNEL = "rhythm_trainer.kelegorm.com/sound"

    private var audioStream: AudioStream? = null


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "playSound") {
                Log.d("rhythm_trainer","received playSound")
                result.success("Sound played")
            } else {
                result.notImplemented()
            }
        }
    }

    // Примерный метод для старта воспроизведения звука
    private fun startAudioPlayback() {
        if (audioStream == null) {
            val builder = AudioStreamBuilder()
            builder.setDirection(Direction.Output)
                .setFormat(AudioFormat.I16)
                .setChannelCount(ChannelCount.MONO)
                .setSampleRate(44100.0f)
                .setSharingMode(SharingMode.Exclusive)

            audioStream = builder.build()
        }

        // Пример звукового буфера для теста
        val buffer = ShortArray(44100) // 1 секунда звука (44100 сэмплов на 44.1kHz)
        for (i in buffer.indices) {
            buffer[i] = (Math.sin(i.toDouble() * 2 * Math.PI * 440.0 / 44100) * Short.MAX_VALUE).toShort() // Генерация синусоиды
        }

        audioStream?.write(buffer)
        audioStream?.start()
    }
}
