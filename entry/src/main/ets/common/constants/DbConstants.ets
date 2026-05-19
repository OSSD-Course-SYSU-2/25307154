export class DbConstants {
  static readonly DB_NAME: string = 'cet4_vocab.db'

  static readonly VOCAB_TABLE: string = 'vocab_progress'
  static readonly VOCAB_COL_WORD: string = 'word'
  static readonly VOCAB_COL_MEANING: string = 'meaning'
  static readonly VOCAB_COL_POS: string = 'pos'
  static readonly VOCAB_COL_CORRECT_COUNT: string = 'correct_count'
  static readonly VOCAB_COL_WRONG_COUNT: string = 'wrong_count'
  static readonly VOCAB_COL_CONSECUTIVE_CORRECT: string = 'consecutive_correct_count'
  static readonly VOCAB_COL_MASTERY_STATUS: string = 'mastery_status'
  static readonly VOCAB_COL_IS_FAVORITE: string = 'is_favorite'
  static readonly VOCAB_COL_FAVORITE_TIME: string = 'favorite_time'

  static readonly ANSWER_TABLE: string = 'answer_record'
  static readonly ANSWER_COL_ID: string = 'id'
  static readonly ANSWER_COL_TARGET_WORD: string = 'target_word'
  static readonly ANSWER_COL_SELECTED_OPTION: string = 'selected_option'
  static readonly ANSWER_COL_CORRECT_OPTION: string = 'correct_option'
  static readonly ANSWER_COL_IS_CORRECT: string = 'is_correct'
  static readonly ANSWER_COL_ANSWER_TIME: string = 'answer_time'

  static readonly CREATE_VOCAB_TABLE_BASE_SQL: string =
    `CREATE TABLE IF NOT EXISTS ${DbConstants.VOCAB_TABLE} (` +
    `${DbConstants.VOCAB_COL_WORD} TEXT PRIMARY KEY NOT NULL, ` +
    `${DbConstants.VOCAB_COL_MEANING} TEXT NOT NULL, ` +
    `${DbConstants.VOCAB_COL_POS} TEXT NOT NULL, ` +
    `${DbConstants.VOCAB_COL_CORRECT_COUNT} INTEGER NOT NULL DEFAULT 0, ` +
    `${DbConstants.VOCAB_COL_WRONG_COUNT} INTEGER NOT NULL DEFAULT 0, ` +
    `${DbConstants.VOCAB_COL_CONSECUTIVE_CORRECT} INTEGER NOT NULL DEFAULT 0, ` +
    `${DbConstants.VOCAB_COL_MASTERY_STATUS} TEXT NOT NULL DEFAULT 'LEARNING')`

  static readonly CREATE_ANSWER_TABLE_SQL: string =
    `CREATE TABLE IF NOT EXISTS ${DbConstants.ANSWER_TABLE} (` +
    `${DbConstants.ANSWER_COL_ID} INTEGER PRIMARY KEY AUTOINCREMENT, ` +
    `${DbConstants.ANSWER_COL_TARGET_WORD} TEXT NOT NULL, ` +
    `${DbConstants.ANSWER_COL_SELECTED_OPTION} INTEGER NOT NULL, ` +
    `${DbConstants.ANSWER_COL_CORRECT_OPTION} INTEGER NOT NULL, ` +
    `${DbConstants.ANSWER_COL_IS_CORRECT} INTEGER NOT NULL, ` +
    `${DbConstants.ANSWER_COL_ANSWER_TIME} INTEGER NOT NULL)`

  static readonly CREATE_INDEX_SQL: string =
    `CREATE INDEX IF NOT EXISTS idx_answer_time ON ${DbConstants.ANSWER_TABLE}(${DbConstants.ANSWER_COL_ANSWER_TIME})`

  static readonly CREATE_FAVORITE_INDEX_SQL: string =
    `CREATE INDEX IF NOT EXISTS idx_favorite_status ON ${DbConstants.VOCAB_TABLE}(${DbConstants.VOCAB_COL_IS_FAVORITE})`

  static readonly CREATE_FAVORITE_TIME_INDEX_SQL: string =
    `CREATE INDEX IF NOT EXISTS idx_favorite_time ON ${DbConstants.VOCAB_TABLE}(${DbConstants.VOCAB_COL_FAVORITE_TIME})`

  static readonly ALTER_ADD_IS_FAVORITE_SQL: string =
    `ALTER TABLE ${DbConstants.VOCAB_TABLE} ADD COLUMN ${DbConstants.VOCAB_COL_IS_FAVORITE} INTEGER NOT NULL DEFAULT 0`

  static readonly ALTER_ADD_FAVORITE_TIME_SQL: string =
    `ALTER TABLE ${DbConstants.VOCAB_TABLE} ADD COLUMN ${DbConstants.VOCAB_COL_FAVORITE_TIME} INTEGER DEFAULT NULL`
}
