import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0001
const TAG = 'CET4Vocab'

export class Logger {
  static info(msg: string): void {
    hilog.info(DOMAIN, TAG, '%{public}s', msg)
  }

  static error(msg: string): void {
    hilog.error(DOMAIN, TAG, '%{public}s', msg)
  }

  static debug(msg: string): void {
    hilog.debug(DOMAIN, TAG, '%{public}s', msg)
  }
}
