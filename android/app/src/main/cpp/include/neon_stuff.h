#pragma once

#include <arm_neon.h>
#include <cstddef>

// Умножает элементы массивов a и b размером size и записывает результат в a.
// Предполагается, что size кратно 4 или остаток обрабатывается в цикле.
//void neonMultiply(float* a, const float* b, std::size_t size) {
//    std::size_t i = 0;
//    // Обрабатываем по 4 элемента за итерацию
//    for (; i + 3 < size; i += 4) {
//        // Загружаем 4 float из a и b (невыравненное чтение)
//        float32x4_t va = vld1q_f32(a + i);
//        float32x4_t vb = vld1q_f32(b + i);
//        // Выполняем умножение
//        float32x4_t vm = vmulq_f32(va, vb);
//        // Сохраняем результат обратно в a
//        vst1q_f32(a + i, vm);
//    }
//    // Обрабатываем остаток элементов
//    for (; i < size; i++) {
//        a[i] *= b[i];
//    }
//}
