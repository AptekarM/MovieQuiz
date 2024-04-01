import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
  
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // Переменная с индексом текущего вопроса, начальное значение 0
    var currentQuestionIndex = 0
    // Переменная со счётчиком правильных ответов, начальное значение 0
    var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        activityIndicator.hidesWhenStopped = true
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // Метод конвертации, который принимает моковый вопрос и возвращает модель представления для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionStep = QuizStepViewModel(
            image: image,
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
        showLoadingIndicator()
        
        questionFactory?.requestNextQuestion()
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
        showLoadingIndicator()
        
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let gamesCompleted = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let bestAttempt = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.formatteDate))"
        
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
            
            self?.hideLoadingIndicator()
        }
    }
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") {
            [weak self] in
            self?.showFirstQuestion()
        }
        AlertPresenter.presentAlert(from: self, with: alertModel)
    }
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
        questionFactory?.loadData()
    }
}
