import { QuitCountShell } from '../features/shell/QuitCountShell';

@Entry
@Component
struct Index {
  build() {
    Column() {
      QuitCountShell()
    }
    .width('100%')
    .height('100%')
  }
}
