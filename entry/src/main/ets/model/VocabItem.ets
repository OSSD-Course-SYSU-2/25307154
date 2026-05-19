import { MasteryStatus } from './Enums'

export interface VocabItem {
  word: string
  meaning: string
  pos: string
  correctCount: number
  wrongCount: number
  consecutiveCorrectCount: number
  masteryStatus: MasteryStatus
  isFavorite: boolean
  favoriteTime: number | null
}

export function createVocabItem(word: string, meaning: string, pos: string): VocabItem {
  return {
    word: word,
    meaning: meaning,
    pos: pos,
    correctCount: 0,
    wrongCount: 0,
    consecutiveCorrectCount: 0,
    masteryStatus: MasteryStatus.LEARNING,
    isFavorite: false,
    favoriteTime: null
  }
}
