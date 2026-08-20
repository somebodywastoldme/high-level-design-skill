# HLD Solution Designer

Кросплатформний AI-скіл, який перетворює короткий опис продукту або системи на
Presales Lite High-Level Design (HLD) у Markdown із діаграмою Mermaid. Один і
той самий процес працює у Claude, Codex, Claude Code та Gemini CLI на macOS і
Windows.

Скіл відокремлює підтверджені вимоги від припущень і критичних запитань. Завдяки
цьому архітектура залишається корисною, але не подає невідомі дані як факти.
Діаграми описують логічні компоненти, їхні обов'язки та потоки без прив'язки до
конкретного хмарного провайдера або деталей розгортання.

## Швидке встановлення для учасників воркшопу

Оберіть застосунок, у якому хочете працювати. Для графічних версій Claude і
Codex не потрібні Gemini CLI, Python, Node.js або API-ключ.

| Застосунок | macOS | Windows | Рекомендований спосіб |
| --- | --- | --- | --- |
| Claude Desktop/Web/Cowork | Так | Так | Завантажити підготовлений ZIP зі скілом |
| Codex Desktop/CLI | Так | Так | Встановити з GitHub через вбудований `$skill-installer` |
| Claude Code | Так | Так | Встановити репозиторій як Claude plugin |
| Gemini CLI | Так | Так | Встановити репозиторій як Gemini extension |

### Варіант A: Claude Desktop, Web або Cowork

Інструкція однакова для macOS і Windows.

> **Важливо:** HLD Solution Designer не опублікований у публічному каталозі
> плагінів або скілів Claude. Завантаження ZIP створює приватний custom skill у
> вашому акаунті Claude. Це не встановлення з Marketplace.

1. [Завантажте останню версію Claude skill](https://github.com/somebodywastoldme/high-level-design-skill/releases/latest/download/ml-system-hld-claude.zip).
   Не розпаковуйте файл.
2. Відкрийте Claude та перейдіть до **Customize → Skills**.
3. Натисніть **+ → Create skill → Upload a skill**.
4. Оберіть `ml-system-hld-claude.zip` та увімкніть **HLD Solution Designer**.
5. Створіть новий чат і вставте перший prompt із розділу
   [Запуск демо](#запуск-демо).

Для Claude Skills має бути ввімкнено **Code execution and file creation**. У
планах Team або Enterprise адміністратор організації також може мати потребу
ввімкнути Skills. Дивіться
[офіційну інструкцію Anthropic](https://support.claude.com/en/articles/12512180-use-skills-in-claude).

Якщо розділу **Customize → Skills** немає, перевірте **Settings → Capabilities →
Code execution and file creation**. У керованому Team або Enterprise workspace
зверніться до адміністратора. Якщо Skills усе одно недоступні, скористайтеся
[Claude Code](#варіант-c-claude-code).

### Варіант B: Codex Desktop або CLI — найпростіший спосіб

Інструкція однакова для macOS і Windows. Відкрийте нову задачу в Codex і
надішліть повідомлення:

```text
Use $skill-installer to install the skill from
https://github.com/somebodywastoldme/high-level-design-skill/tree/main/skills/ml-system-hld
```

Дочекайтеся завершення встановлення, а потім створіть **нову задачу Codex**, щоб
Codex завантажив новий скіл. Викличте його через `$ml-system-hld` або вставте
перший prompt із розділу [Запуск демо](#запуск-демо).

#### Ручне встановлення Codex на macOS

Скористайтеся цим способом, якщо репозиторій уже клоновано або завантажено:

```bash
cd /path/to/high-level-design-skill
mkdir -p ~/.codex/skills
cp -R skills/ml-system-hld ~/.codex/skills/
```

Перевірте встановлення:

```bash
test -f ~/.codex/skills/ml-system-hld/SKILL.md && echo "HLD skill installed"
```

#### Ручне встановлення Codex на Windows

Відкрийте **PowerShell** у папці завантаженого репозиторію та виконайте:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse -Force ".\skills\ml-system-hld" "$env:USERPROFILE\.codex\skills\"
```

Перевірте встановлення:

```powershell
Test-Path "$env:USERPROFILE\.codex\skills\ml-system-hld\SKILL.md"
```

PowerShell має вивести `True`. Після ручного встановлення перезапустіть Codex
або створіть нову задачу.

### Варіант C: Claude Code

Виконайте ці команди всередині Claude Code. Вони однакові для macOS і Windows:

```text
/plugin marketplace add somebodywastoldme/high-level-design-skill
/plugin install hld@hld-designer
```

Плагін додає команди `/hld:requirements` і `/hld:design`.

## Запуск демо

Працюйте з папки проєкту, у якій потрібно створити `requirements.md` і
`hld.md`.

### Крок 1 — discovery та вимоги

У Claude або Codex вставте:

```text
Використай HLD Solution Designer. Проведи зі мною інтерв'ю щодо B2B-платформи,
яка отримує контракти, перевіряє їх, передає винятки спеціалістам та
інтегрується з CRM. Підготуй requirements.md, але запиши файл лише після того,
як я підтверджу чернетку.
```

Асистент ставитиме по одному запитанню та розділятиме **підтверджені факти**,
**припущення** і **невідомі дані**. Коли чернетка буде готова, підтвердьте її.

### Крок 2 — архітектура

У тому самому проєкті вставте:

```text
Використай HLD Solution Designer. Прочитай затверджений requirements.md і створи
vendor-neutral Presales Lite HLD із Mermaid-діаграмою архітектури. Запиши
результат у hld.md.
```

Очікуваний результат:

- `requirements.md` — затверджені вимоги та реєстр тверджень;
- `hld.md` — базова архітектура, Mermaid-діаграма, обґрунтування, ризики,
  альтернативи та відкриті запитання.

## Встановлення у Gemini CLI

Встановіть extension безпосередньо з GitHub:

```bash
gemini extensions install https://github.com/somebodywastoldme/high-level-design-skill
```

Для локальної розробки:

```bash
gemini extensions install /path/to/high-level-design-skill
```

Перевірте встановлення:

```bash
gemini extensions list
```

У списку має з'явитися `hld-ml-designer`.

Щоб отримати нову версію після її публікації на GitHub, перезапустіть Gemini CLI
та виконайте:

```bash
gemini extensions update --all
```

## Локальна розробка з Claude Code

Щоб тестувати зміни без marketplace, запустіть Claude Code з кореневої папки
репозиторію:

```bash
claude --plugin-dir .
```

Після редагування виконайте `/reload-plugins`.

## Збирання пакетів для розповсюдження

Учасникам воркшопу не потрібно збирати пакети самостійно. Готові ZIP-файли
публікуються на сторінці
[GitHub Releases](https://github.com/somebodywastoldme/high-level-design-skill/releases).

Maintainer може перевірити складання локально на macOS або Linux:

```bash
./scripts/build-demo-packages.sh
```

Скрипт створює:

- `dist/ml-system-hld-claude.zip` для ручного завантаження у Claude;
- `dist/hld-codex-plugin.zip` для майбутньої публікації через Codex marketplace.

Папка `dist/` не зберігається в Git. GitHub Actions автоматично перебудовує
обидва ZIP-файли, створює `SHA256SUMS.txt` та прикріплює їх до GitHub Release.

## Публікація нової версії через GitHub

Для публікації не потрібно вручну збирати або завантажувати ZIP-файли.

1. Переконайтеся, що всі потрібні зміни вже об'єднані з гілкою `main`.
2. Відкрийте сторінку **Releases** у GitHub.
3. Натисніть **Draft a new release**.
4. Натисніть **Choose a tag → Create new tag** і введіть номер, наприклад
   `v0.1.0`. Оберіть гілку `main`.
5. У полі заголовка введіть `HLD Solution Designer v0.1.0`.
6. Натисніть **Publish release**.
7. Відкрийте вкладку **Actions** і дочекайтеся завершення workflow
   **Publish skill packages**.

Після успішного workflow у Release з'являться:

- `ml-system-hld-claude.zip`;
- `hld-codex-plugin.zip`;
- `SHA256SUMS.txt`.

Посилання **Завантажте останню версію Claude skill** на початку README завжди
веде на ZIP із найновішого GitHub Release.

## Використання slash-команд

У Gemini CLI та Claude Code доступний процес із двох команд:

```text
/hld:requirements "B2B-платформа отримує контракти, перевіряє їх, передає винятки спеціалістам та інтегрується з CRM."
/hld:design
```

### Крок 1 — формування вимог

Запустіть:

```text
/hld:requirements "система модерації завантажених зображень товарів зі швидкістю 2000 зображень на хвилину"
```

Скіл проведе інтерактивне discovery-інтерв'ю за шістьма категоріями: бізнес-ціль,
користувачі, функціональний обсяг, масштаб, дані та інтеграції, безпека й
обмеження. Після вашого підтвердження він створить `requirements.md`.

### Крок 2 — створення HLD

Після затвердження `requirements.md` виконайте:

```text
/hld:design
```

Скіл створить `hld.md` із вісьмома обов'язковими розділами, логічною
Mermaid-діаграмою, базовим рішенням, компромісами, discovery-запитаннями та не
більш ніж двома умовними альтернативами.

> Запускайте команди з папки, у якій мають знаходитися `requirements.md` і
> `hld.md`.

## Що ви отримаєте

`hld.md` міститиме:

- vendor-neutral логічну архітектуру;
- читабельну Mermaid-діаграму;
- таблицю компонентів та їхніх обов'язків;
- зв'язок між вимогами й архітектурними рішеннями;
- ризики, припущення та відкриті запитання;
- базовий варіант і щонайбільше дві умовні альтернативи.

Mermaid-блок можна відкрити в IDE, GitHub Wiki або
[Mermaid Live](https://mermaid.live).

## Ручний smoke test

Після встановлення запустіть:

```text
/hld:requirements "B2B-платформа отримує контракти, перевіряє їх, передає винятки спеціалістам та інтегрується з CRM."
/hld:design
```

Перевірте, що:

- `requirements.md` відокремлює факти, припущення та критичні запитання;
- скіл не вигадує точний SLA або навантаження;
- `hld.md` містить усі вісім Presales Lite розділів;
- Mermaid-діаграма використовує vendor-neutral логічні компоненти;
- вказано базову архітектуру, компроміси та discovery-запитання;
- запропоновано не більше двох альтернатив;
- немає cloud-vendor mapping або деталей рівня LLD.

## Усунення проблем

### Claude не показує розділ Skills

Увімкніть **Settings → Capabilities → Code execution and file creation**. Для
Team або Enterprise зверніться до адміністратора організації. Якщо розділ не
з'являється, використайте Claude Code.

### Codex не бачить `$ml-system-hld`

Переконайтеся, що існує файл:

- macOS: `~/.codex/skills/ml-system-hld/SKILL.md`;
- Windows: `%USERPROFILE%\.codex\skills\ml-system-hld\SKILL.md`.

Після встановлення створіть нову задачу Codex.

### Gemini або Claude Code не показує slash-команди

Для Gemini CLI виконайте:

```text
/commands reload
```

Для Claude Code виконайте:

```text
/reload-plugins
```

### Mermaid-діаграма не рендериться

Вставте блок `mermaid` у [Mermaid Live](https://mermaid.live), перевірте
синтаксис і повторно запустіть `/hld:design`.
