import { SessionStatus } from './Enums'

export interface QuizSession {
  sessionId: string
  startTime: number
  endTime: number | null
  status: SessionStatus
  answeredCount: number
  correctCount: number
}
