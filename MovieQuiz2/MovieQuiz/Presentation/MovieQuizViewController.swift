import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    let questionsAmount: Int = 10
    var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    var currentQuestion: QuizQuestion?
    
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
       
        let questionFactory = QuestionFactory()
        
                questionFactory.setup(delegate: self)
                self.questionFactory = questionFactory
        // Показать первый вопрос
        showFirstQuestion()
    }
    
    // Метод конвертации, который принимает моковый вопрос и возвращает модель представления для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
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
        questionFactory.requestNextQuestion()
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
        
        // Используем [weak self]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }
    
    // Метод для сброса цвета рамки картинки
    func resetBorderColor() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Показать следующий вопрос или результаты
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    func showResults() {
        self.statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
        
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let gamesCompleted = "Количество сыграных квизов: \(self.statisticService.gamesCount)"
        let bestAttempt = "Рекорд: \(self.statisticService.bestGame.correct)/\(self.statisticService.bestGame.total) (\(self.statisticService.bestGame.formatteDate))"
        
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let alertMessage = "\(currentGameResult)\n\(gamesCompleted)\n\(bestAttempt)\n\(averageAccuracy)"
        let alertModel = AlertModel(title: "Этот раунд окончен!", message: alertMessage, buttonText: "Сыграть еще раз") {
            
            self.resetQuiz()
        }
        AlertPresenter.presentAlert(from: self, with: alertModel)
    }
    
    // MARK: - Buttons
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        let correctAnswer = currentQuestion?.correctAnswer ?? false
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let givenAnswer = false
        let correctAnswer = currentQuestion?.correctAnswer ?? false
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    // Метод для сброса состояния квиза
    func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showFirstQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
