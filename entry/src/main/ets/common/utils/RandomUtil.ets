export class RandomUtil {
  static shuffle<T>(array: T[]): T[] {
    const result = [...array]
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = result[i]
      result[i] = result[j]
      result[j] = temp
    }
    return result
  }

  static randomPick<T>(array: T[], count: number): T[] {
    const shuffled = RandomUtil.shuffle(array)
    return shuffled.slice(0, Math.min(count, shuffled.length))
  }

  static randomIndex(max: number): number {
    return Math.floor(Math.random() * max)
  }
}
