import UIKit

// Структура для представления вопроса в квизе
struct QuizQuestion {
    // Строка с названием фильма, совпадает с названием картинки афиши фильма в Assets
    let image: String
    // Строка с вопросом о рейтинге фильма
    let text: String
    // Булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

// Структура представления для состояния "Вопрос показан"
struct QuizStepViewModel {
    // Картинка с афишей фильма с типом UIImage
    let image: UIImage
    // Вопрос о рейтинге квиза
    let question: String
    // Строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}

// Структура представления для состояния "Результат квиза"
struct QuizResultsViewModel {
    // Строка с заголовком алерта
    let title: String
    // Строка с текстом о количестве набранных очков
    let text: String
    // Текст для кнопки алерта
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // Переменная с индексом текущего вопроса, начальное значение 0
    var currentQuestionIndex = 0
    // Переменная со счётчиком правильных ответов, начальное значение 0
    var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Показать первый вопрос
        showFirstQuestion()
    }
    
    // Метод конвертации, который принимает моковый вопрос и возвращает модель представления для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
        return questionStep
    }
    
    // Метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        resetBorderColor()
    }
    
    // Показать первый вопрос
    func showFirstQuestion() {
        let firstQuestion = convert(model: questions[currentQuestionIndex])
        show(quiz: firstQuestion)
    }
    
    // Метод для отображения результата ответа
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        imageView.layer.borderColor = isCorrect ?
        UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // Метод для сброса цвета рамки картинки
    func resetBorderColor() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Показать следующий вопрос или результаты
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    // Метод для отображения результатов квиза
    func showResults() {
        let resultText = "Ваш результат: \(correctAnswers) из \(questions.count)"
        let resultsViewModel = QuizResultsViewModel(title: "Результат", text: resultText, buttonText: "Начать заново")
        
        let alert = UIAlertController(title: resultsViewModel.title, message: resultsViewModel.text, preferredStyle: .alert)
        let action = UIAlertAction(title: resultsViewModel.buttonText, style: .default) { _ in
            self.resetQuiz()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Buttons
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let givenAnswer = false
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    // Метод для сброса состояния квиза
    func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showFirstQuestion()
    }
}


