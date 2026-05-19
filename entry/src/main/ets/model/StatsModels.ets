export interface ProgressSummary {
  totalVocabCount: number
  masteredCount: number
  learningCount: number
  overallAccuracy: number | null
}

export interface TodayStats {
  todayAnsweredCount: number
  todayAccuracy: number | null
}

export interface AnswerResult {
  isCorrect: boolean
  correctMeaning: string
}

export interface SessionProgress {
  answeredCount: number
  correctCount: number
}
