import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { VocabDbService } from '../service/VocabDbService'
import { QuizService } from '../service/QuizService'
import { Logger } from '../common/log/Logger'

const DOMAIN = 0x0000

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err))
    }
    try {
      const dbService = VocabDbService.getInstance()
      await dbService.initDb(this.context)
      await dbService.loadVocabFromRawFile()

      const quizService = QuizService.getInstance()
      await quizService.initPreferences(this.context)

      Logger.info('App initialized successfully')
    } catch (err) {
      Logger.error(`Failed to initialize app: ${JSON.stringify(err)}`)
    }
  }

  onDestroy(): void {
    Logger.info('Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info('Ability onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err))
        return
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.')
    })
  }

  onWindowStageDestroy(): void {
    Logger.info('Ability onWindowStageDestroy')
  }

  onForeground(): void {
    Logger.info('Ability onForeground')
  }

  onBackground(): void {
    Logger.info('Ability onBackground')
  }
}
