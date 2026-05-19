export interface QuizOption {
  index: number
  meaning: string
}

export interface QuizQuestion {
  targetWord: string
  correctMeaning: string
  options: QuizOption[]
  correctOptionIndex: number
}
