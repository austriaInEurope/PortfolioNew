import SwiftUI

// Основная View для экрана выхода из аккаунта
struct AccountExitView: View {
    // Состояние для контроля отображения алерта
    @State private var showingLogoutAlert = false
    // Состояние для управления анимацией выхода
    @State private var isLoggingOut = false
    
    var body: some View {
        // Вертикальный стек для организации элементов
        VStack {
            // Spacer занимает все доступное пространство сверху
            Spacer()
            
            // Основная кнопка выхода
            Button(action: {
                // При нажатии показываем алерт подтверждения
                showingLogoutAlert = true
            }) {
                // Горизонтальный стек для иконки и текста
                HStack(spacing: 15) {
                    // Иконка выхода с bounce-анимацией
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .symbolEffect(.bounce, value: isLoggingOut)
                    
                    // Текст кнопки
                    Text("Выйти из аккаунта")
                        .font(.system(size: 18, weight: .semibold))
                }
                // Стилизация содержимого кнопки:
                .foregroundColor(.white) // Белый текст
                .padding() // Внутренние отступы
                .frame(maxWidth: .infinity) // На всю доступную ширину
                // Градиентный фон кнопки от синего к фиолетовому
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15) // Закругление углов
                // Тень кнопки красноватого оттенка
                .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                // Внешние отступы по бокам
                .padding(.horizontal, 40)
                // Анимация масштаба при выходе
                .scaleEffect(isLoggingOut ? 0.95 : 1.0)
            }
            // Применяем кастомный стиль кнопки
            .buttonStyle(ScaleButtonStyle())
            
            // Алерт подтверждения выхода
            .alert("Подтверждение выхода", isPresented: $showingLogoutAlert) {
                // Кнопка отмены
                Button("Отмена", role: .cancel) {}
                // Кнопка выхода (деструктивное действие)
                Button("Выйти", role: .destructive) {
                    // Анимация при выходе
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoggingOut = true
                    }
                    // Задержка перед выполнением выхода (для завершения анимации)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Здесь должна быть реальная логика выхода
                        print("Пользователь вышел из системы")
                    }
                }
            } message: {
                // Текст сообщения в алерте
                Text("Вы уверены, что хотите выйти из своего аккаунта?")
            }
        }
        // Отступ снизу для всего контейнера
        .padding(.bottom, 50)
    }
}

// Кастомный стиль для кнопки с анимацией при нажатии
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Уменьшение кнопки при нажатии
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            // Легкое затемнение при нажатии
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            // Плавная анимация изменений
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Предварительный просмотр (возможно, здесь опечатка - должно быть AccountExitView)
#Preview {
    AccountExitView() // Исправлено на правильное имя View
        .preferredColorScheme(.dark) // Темная тема для превью
}
