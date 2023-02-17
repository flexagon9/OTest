const fs = require('fs')
const chalk = require('chalk')

fs.rename(
  'src/model/graphql/types/globalTypes',
  'src/model/graphql/types/globalTypes.ts',
  (err) => {
    if (err) {
      console.log(`${chalk.red(err)}`)
    } else {
      console.log(`${chalk.green('√')} Renamed global types`)
    }
  }
)
